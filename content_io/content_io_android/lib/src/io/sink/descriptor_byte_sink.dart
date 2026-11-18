import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:content_io_android/src/exceptions/content_write_exception.dart';
import 'package:content_io_android/src/io/sink/content_byte_sink.dart';
import 'package:content_io_android/src/io/source/native_descriptor_io.dart';

/// A [ContentByteSink] for a file descriptor, written with libc over FFI.
///
/// - Owns the descriptor, and closes it on [close], [abort], or when garbage
///   collected.
/// - Writes with `write`, and syncs with `fsync` on [close].
/// - Writes run on a worker isolate of the sink's own, so they never block
///   the calling isolate, even on a pipe that waits for its reader.
final class DescriptorByteSink extends ContentByteSink {
  /// Closes the descriptor of sinks garbage collected without being closed.
  static final _finalizer = Finalizer<_DescriptorWriter>((it) => it.abort());

  /// Writes the descriptor on the worker isolate.
  final _DescriptorWriter _writer;

  @override
  final String id;

  DescriptorByteSink({required this.id, required int fd})
    : _writer = _DescriptorWriter(fd) {
    _finalizer.attach(this, _writer, detach: this);
  }

  @override
  Future<void> write(Uint8List bytes) => _writer.write(bytes);

  @override
  Future<void> close() {
    _finalizer.detach(this);
    return _writer.close();
  }

  @override
  Future<void> abort() {
    _finalizer.detach(this);
    return _writer.abort();
  }
}

/// The main-isolate side of a [DescriptorByteSink]'s worker isolate.
///
/// Note:
/// Separate from the sink, so the finalizer can close the descriptor after
/// the sink is garbage collected.
final class _DescriptorWriter {
  /// The number of bytes copied to native memory per worker request.
  static const _pieceSize = 1024 * 1024;

  /// The worker, once started by the first write or [close].
  Future<_Worker>? _worker;

  /// Whether [close] or [abort] has been called.
  bool _isClosed = false;

  /// The owned file descriptor.
  final int _fd;

  _DescriptorWriter(this._fd);

  /// Writes all of [bytes] to the descriptor on the worker.
  ///
  /// Throws:
  /// - [ContentWriteException] if the write fails, or the worker can't run.
  /// - [OutOfMemoryError] if the native buffer can't be allocated.
  Future<void> write(Uint8List bytes) async {
    if (bytes.isEmpty) {
      return;
    }

    final worker = await (_worker ??= _Worker.start(_fd));
    for (var start = 0; start < bytes.length; start += _pieceSize) {
      final count = min(_pieceSize, bytes.length - start);
      final buffer = NativeDescriptorIo.allocate(count);
      try {
        buffer.asTypedList(count).setRange(0, count, bytes, start);
        await worker.send(_DrainRequest(address: buffer.address, count: count));
      } finally {
        NativeDescriptorIo.free(buffer);
      }
    }
  }

  /// Syncs the descriptor, then closes it, on the worker.
  ///
  /// Throws:
  /// - [ContentWriteException] if the sync fails, or the worker can't run.
  ///
  /// Note:
  /// Has no effect after the first call to it or [abort]. The descriptor is
  /// closed even when it throws.
  Future<void> close() async {
    if (_isClosed) {
      return;
    }
    _isClosed = true;

    final _Worker worker;
    try {
      worker = await (_worker ??= _Worker.start(_fd));
    } on ContentWriteException {
      // The worker never started, so the descriptor is still open here.
      NativeDescriptorIo.close(_fd);
      rethrow;
    }
    await worker.send(const _SyncRequest());
  }

  /// Closes the descriptor without syncing, on the worker when one was
  /// started.
  ///
  /// Note:
  /// Has no effect after the first call to it or [close]. Never throws.
  Future<void> abort() async {
    if (_isClosed) {
      return;
    }
    _isClosed = true;

    final worker = _worker;
    if (worker == null) {
      NativeDescriptorIo.close(_fd);
      return;
    }
    try {
      (await worker).stop();
    } on ContentWriteException {
      // The worker never started, so the descriptor is still open here.
      NativeDescriptorIo.close(_fd);
    }
  }
}

/// A worker isolate that writes one descriptor from memory the main isolate
/// allocates.
///
/// Note:
/// Requests are handled one at a time; the next is sent only after the
/// previous one's reply.
final class _Worker {
  /// The reply to the request in progress, if any.
  Completer<void>? _pending;

  /// Sends requests to the worker.
  final SendPort _requests;

  _Worker._(this._requests);

  /// Starts a worker for [fd].
  ///
  /// Parameters:
  /// - [fd]: the descriptor to write; the worker closes it on a
  ///   [_SyncRequest] or on [stop].
  ///
  /// Returns: the started worker.
  ///
  /// Throws:
  /// - [WriteException] if the worker can't be started.
  static Future<_Worker> start(int fd) async {
    final replies = ReceivePort();
    final ready = Completer<SendPort>();
    _Worker? worker;

    replies.listen((message) {
      switch (message) {
        case final SendPort requests when !ready.isCompleted:
          ready.complete(requests);
        case _Done():
          worker?._complete();
        case final _WriteFailure failure:
          worker?._fail(failure.toException(), failure.trace);
        case null:
          // The worker exited.
          worker?._fail(
            const WriteException('The descriptor writer stopped'),
            StackTrace.current.toString(),
          );
          replies.close();
          if (!ready.isCompleted) {
            ready.completeError(
              const WriteException('The descriptor writer stopped'),
            );
          }
      }
    });

    try {
      await Isolate.spawn(
        _run,
        _WorkerStart(fd: fd, replies: replies.sendPort),
        onExit: replies.sendPort,
        debugName: 'DescriptorByteSink',
      );
      return worker = _Worker._(await ready.future);
    } on IsolateSpawnException catch (e, stackTrace) {
      replies.close();
      Error.throwWithStackTrace(WriteException(e.toString()), stackTrace);
    }
  }

  /// Sends [request] to the worker.
  ///
  /// Parameters:
  /// - [request]: what to write, or a sync.
  ///
  /// Throws:
  /// - [ContentWriteException] if the request fails, or the worker stopped.
  Future<void> send(Object request) {
    final pending = Completer<void>();
    _pending = pending;
    _requests.send(request);
    return pending.future;
  }

  /// Asks the worker to close the descriptor and exit, without syncing.
  void stop() => _requests.send(const _StopRequest());

  void _complete() {
    final pending = _pending;
    _pending = null;
    pending?.complete();
  }

  void _fail(ContentWriteException exception, String trace) {
    final pending = _pending;
    _pending = null;
    pending?.completeError(exception, StackTrace.fromString(trace));
  }

  /// The worker isolate's entry point.
  ///
  /// Parameters:
  /// - [start]: the descriptor, and where to send replies.
  static void _run(_WorkerStart start) {
    final requests = ReceivePort();
    start.replies.send(requests.sendPort);

    requests.listen((message) {
      switch (message) {
        case final _DrainRequest request:
          try {
            _drain(start.fd, request);
            start.replies.send(const _Done());
          } on OSError catch (e, stackTrace) {
            start.replies.send(_WriteFailure.of(e, stackTrace));
          }
        case _SyncRequest():
          try {
            _sync(start.fd);
            start.replies.send(const _Done());
          } on OSError catch (e, stackTrace) {
            start.replies.send(_WriteFailure.of(e, stackTrace));
          } finally {
            NativeDescriptorIo.close(start.fd);
            requests.close();
          }
        case _StopRequest():
          NativeDescriptorIo.close(start.fd);
          requests.close();
      }
    });
  }

  /// Writes all of the memory [request] points to into [fd].
  ///
  /// Throws:
  /// - [OSError] if a write fails.
  static void _drain(int fd, _DrainRequest request) {
    var written = 0;
    while (written < request.count) {
      written += NativeDescriptorIo.write(
        fd,
        Pointer<Uint8>.fromAddress(request.address + written),
        request.count - written,
      );
    }
  }

  /// Syncs [fd], unless it's a descriptor that can't be synced, such as a
  /// pipe.
  ///
  /// Throws:
  /// - [OSError] if the sync fails.
  static void _sync(int fd) {
    try {
      NativeDescriptorIo.fsync(fd);
    } on OSError catch (e) {
      final code = e.errorCode;
      if (code != NativeDescriptorIo.einval &&
          code != NativeDescriptorIo.erofs) {
        rethrow;
      }
    }
  }
}

/// What a worker starts with.
final class _WorkerStart {
  /// The descriptor to write.
  final int fd;

  /// Where to send replies.
  final SendPort replies;

  const _WorkerStart({required this.fd, required this.replies});
}

/// A request to write native memory to the descriptor.
final class _DrainRequest {
  /// The address of the memory to write from.
  final int address;

  /// The number of bytes to write.
  final int count;

  const _DrainRequest({required this.address, required this.count});
}

/// A request to sync the descriptor, then close it and exit.
final class _SyncRequest {
  const _SyncRequest();
}

/// A request to close the descriptor and exit, without syncing.
final class _StopRequest {
  const _StopRequest();
}

/// A request that succeeded.
final class _Done {
  const _Done();
}

/// A failed request, as the worker reports it.
final class _WriteFailure {
  /// A description of the failure.
  final String message;

  /// The system's error code.
  final int errorCode;

  /// The stack trace of the failure.
  final String trace;

  const _WriteFailure({
    required this.message,
    required this.errorCode,
    required this.trace,
  });

  factory _WriteFailure.of(OSError error, StackTrace stackTrace) {
    return _WriteFailure(
      message: error.toString(),
      errorCode: error.errorCode,
      trace: stackTrace.toString(),
    );
  }

  /// The exception the failure is reported as.
  ContentWriteException toException() {
    return errorCode == NativeDescriptorIo.enospc
        ? NotEnoughSpaceException(message)
        : WriteException(message);
  }
}
