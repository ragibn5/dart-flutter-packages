import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:media_provider_android/src/exceptions/media_read_exception.dart';
import 'package:media_provider_android/src/io/source/media_byte_source.dart';
import 'package:media_provider_android/src/io/source/native_descriptor_io.dart';

/// A [MediaByteSource] for a file descriptor, read with libc over FFI.
///
/// - Owns the descriptor, and closes it on [close] or when garbage collected.
/// - Reads seekable descriptors with `pread64`, others with `read`.
/// - Reads run on a worker isolate of the source's own, so they never block
///   the calling isolate, even on a pipe that waits for its writer.
/// - Reads go straight into native memory, returned without copying.
final class DescriptorByteSource extends MediaByteSource {
  /// The number of bytes requested per read when [readAll] doesn't know the
  /// size.
  static const _pieceSize = 1024 * 1024;

  /// Closes the descriptor of sources garbage collected without being closed.
  static final _finalizer = Finalizer<_DescriptorReader>((it) => it.close());

  /// The current position, from the item's start.
  ///
  /// Used only when [isSeekable]; other descriptors keep their own position.
  int _position = 0;

  /// Reads the descriptor on the worker isolate.
  final _DescriptorReader _reader;

  /// The offset of the item's first byte in the descriptor. Non-zero for a
  /// section of a larger file.
  final int _offset;

  @override
  final String id;

  @override
  final int? length;

  @override
  final bool isSeekable;

  DescriptorByteSource({
    required this.id,
    required int fd,
    int offset = 0,
    required this.length,
    required this.isSeekable,
  }) : _reader = _DescriptorReader(fd),
       _offset = offset {
    _finalizer.attach(this, _reader, detach: this);
  }

  @override
  Future<Uint8List> read(int maxLength, {int? position}) async {
    if (position != null) {
      _seek(position);
    }
    // Non-seekable descriptors return after the first non-empty read.
    return _fill(_limitToRemaining(maxLength), untilFull: isSeekable);
  }

  @override
  Future<Uint8List> readAll({int? position}) async {
    if (position != null) {
      _seek(position);
    }
    final itemLength = length;
    if (itemLength == null) {
      return readToEnd(_pieceSize);
    }

    // Known size: reads into one buffer of that size.
    return _fill(max(0, itemLength - _position), untilFull: true);
  }

  @override
  Future<void> close() {
    _finalizer.detach(this);
    return _reader.close();
  }

  /// Moves the current position to [position].
  ///
  /// Throws:
  /// - [RangeError] if [position] is negative.
  /// - [UnsupportedError] if the descriptor isn't [isSeekable].
  void _seek(int position) {
    RangeError.checkNotNegative(position, 'position');
    if (!isSeekable) {
      throw UnsupportedError('The descriptor is not seekable');
    }
    _position = position;
  }

  /// Limits a read size to the bytes left in the item.
  ///
  /// Parameters:
  /// - [maxLength]: the requested number of bytes.
  ///
  /// Returns: [maxLength], or the bytes left after the current position when
  /// fewer; always [maxLength] when [length] is unknown.
  int _limitToRemaining(int maxLength) {
    final itemLength = length;
    return itemLength == null
        ? maxLength
        : max(0, min(maxLength, itemLength - _position));
  }

  /// Reads from the current position, and advances the position by the bytes
  /// read.
  ///
  /// Parameters:
  /// - [count]: the maximum number of bytes to read.
  /// - [untilFull]: whether to keep reading until [count] bytes are read; when
  ///   `false`, stops after the first non-empty read.
  ///
  /// Returns: the bytes read; fewer than [count] at the end of the descriptor.
  ///
  /// Throws:
  /// - [ReadException] if a read fails.
  /// - [OutOfMemoryError] if the buffer can't be allocated.
  Future<Uint8List> _fill(int count, {required bool untilFull}) async {
    final bytes = await _reader.read(
      count,
      offset: isSeekable ? _offset + _position : null,
      untilFull: untilFull,
    );
    _position += bytes.length;
    return bytes;
  }
}

/// The main-isolate side of a [DescriptorByteSource]'s worker isolate.
///
/// Note:
/// Separate from the source, so the finalizer can close the descriptor after
/// the source is garbage collected.
final class _DescriptorReader {
  /// The worker, once started by the first read.
  Future<_Worker>? _worker;

  /// Whether [close] has been called.
  bool _isClosed = false;

  /// The owned file descriptor.
  final int _fd;

  _DescriptorReader(this._fd);

  /// Reads from the descriptor on the worker.
  ///
  /// Parameters:
  /// - [count]: the maximum number of bytes to read.
  /// - [offset]: the descriptor offset to read from, with `pread64`; or `null`
  ///   to read from the descriptor's own position, with `read`.
  /// - [untilFull]: whether to keep reading until [count] bytes are read.
  ///
  /// Returns: the bytes read, in native memory freed when the list is garbage
  /// collected.
  ///
  /// Throws:
  /// - [ReadException] if the read fails, or the worker can't run.
  /// - [OutOfMemoryError] if the buffer can't be allocated.
  Future<Uint8List> read(
    int count, {
    required int? offset,
    required bool untilFull,
  }) async {
    if (count == 0) {
      return Uint8List(0);
    }

    final worker = await (_worker ??= _Worker.start(_fd));
    final buffer = NativeDescriptorIo.allocate(count);
    final int filled;
    try {
      filled = await worker.fill(
        _FillRequest(
          address: buffer.address,
          count: count,
          offset: offset,
          untilFull: untilFull,
        ),
      );
    } catch (_) {
      NativeDescriptorIo.free(buffer);
      rethrow;
    }

    if (filled == 0) {
      NativeDescriptorIo.free(buffer);
      return Uint8List(0);
    }
    return buffer.asTypedList(
      filled,
      finalizer: NativeDescriptorIo.freeFinalizer.cast(),
    );
  }

  /// Closes the descriptor, on the worker when one was started.
  ///
  /// Note:
  /// Has no effect after the first call. Never throws.
  Future<void> close() async {
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
    } on ReadException {
      // The worker never started, so the descriptor is still open here.
      NativeDescriptorIo.close(_fd);
    }
  }
}

/// A worker isolate that reads one descriptor into memory the main isolate
/// allocates.
///
/// Note:
/// Requests are handled one at a time; the next is sent only after the
/// previous one's reply.
final class _Worker {
  /// The reply to the request in progress, if any.
  Completer<int>? _pending;

  /// Sends requests to the worker.
  final SendPort _requests;

  _Worker._(this._requests);

  /// Starts a worker for [fd].
  ///
  /// Parameters:
  /// - [fd]: the descriptor to read; the worker closes it on [stop].
  ///
  /// Returns: the started worker.
  ///
  /// Throws:
  /// - [ReadException] if the worker can't be started.
  static Future<_Worker> start(int fd) async {
    final replies = ReceivePort();
    final ready = Completer<SendPort>();
    _Worker? worker;

    replies.listen((message) {
      switch (message) {
        case final SendPort requests when !ready.isCompleted:
          ready.complete(requests);
        case final int filled:
          worker?._complete(filled);
        case final _FillFailure failure:
          worker?._fail(failure.message, StackTrace.fromString(failure.trace));
        case null:
          // The worker exited.
          worker?._fail('The descriptor reader stopped', StackTrace.current);
          replies.close();
          if (!ready.isCompleted) {
            ready.completeError(
              const ReadException('The descriptor reader stopped'),
            );
          }
      }
    });

    try {
      await Isolate.spawn(
        _run,
        _WorkerStart(fd: fd, replies: replies.sendPort),
        onExit: replies.sendPort,
        debugName: 'DescriptorByteSource',
      );
      return worker = _Worker._(await ready.future);
    } on IsolateSpawnException catch (e, stackTrace) {
      replies.close();
      Error.throwWithStackTrace(ReadException(e.toString()), stackTrace);
    }
  }

  /// Sends [request] to the worker.
  ///
  /// Parameters:
  /// - [request]: what to read, and where to put it.
  ///
  /// Returns: the number of bytes read.
  ///
  /// Throws:
  /// - [ReadException] if the read fails, or the worker stopped.
  Future<int> fill(_FillRequest request) {
    final pending = Completer<int>();
    _pending = pending;
    _requests.send(request);
    return pending.future;
  }

  /// Asks the worker to close the descriptor and exit.
  void stop() => _requests.send(const _StopRequest());

  void _complete(int filled) {
    final pending = _pending;
    _pending = null;
    pending?.complete(filled);
  }

  void _fail(String message, StackTrace stackTrace) {
    final pending = _pending;
    _pending = null;
    pending?.completeError(ReadException(message), stackTrace);
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
        case final _FillRequest request:
          try {
            start.replies.send(_fill(start.fd, request));
          } on OSError catch (e, stackTrace) {
            start.replies.send(
              _FillFailure(message: e.toString(), trace: stackTrace.toString()),
            );
          }
        case _StopRequest():
          NativeDescriptorIo.close(start.fd);
          requests.close();
      }
    });
  }

  /// Reads from [fd] into the memory [request] points to.
  ///
  /// Parameters:
  /// - [fd]: the descriptor to read.
  /// - [request]: what to read, and where to put it.
  ///
  /// Returns: the number of bytes read; less than the requested count at the
  /// end of the descriptor.
  ///
  /// Throws:
  /// - [OSError] if a read fails.
  static int _fill(int fd, _FillRequest request) {
    var filled = 0;
    while (filled < request.count) {
      final target = Pointer<Uint8>.fromAddress(request.address + filled);
      final remaining = request.count - filled;
      final offset = request.offset;
      final read = offset == null
          ? NativeDescriptorIo.read(fd, target, remaining)
          : NativeDescriptorIo.pread(fd, target, remaining, offset + filled);
      if (read == 0) {
        break;
      }
      filled += read;
      if (!request.untilFull) {
        break;
      }
    }
    return filled;
  }
}

/// What a worker starts with.
final class _WorkerStart {
  /// The descriptor to read.
  final int fd;

  /// Where to send replies.
  final SendPort replies;

  const _WorkerStart({required this.fd, required this.replies});
}

/// A request to read into native memory.
final class _FillRequest {
  /// The address of the memory to read into.
  final int address;

  /// The maximum number of bytes to read.
  final int count;

  /// The descriptor offset to read from, or `null` for the descriptor's own
  /// position.
  final int? offset;

  /// Whether to keep reading until [count] bytes are read.
  final bool untilFull;

  const _FillRequest({
    required this.address,
    required this.count,
    required this.offset,
    required this.untilFull,
  });
}

/// A request to close the descriptor and exit.
final class _StopRequest {
  const _StopRequest();
}

/// A failed read, as the worker reports it.
final class _FillFailure {
  /// A description of the failure.
  final String message;

  /// The stack trace of the failure.
  final String trace;

  const _FillFailure({required this.message, required this.trace});
}
