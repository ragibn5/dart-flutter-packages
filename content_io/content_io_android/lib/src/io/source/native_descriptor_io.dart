import 'dart:ffi';
import 'dart:io';

/// libc descriptor and memory functions, called over FFI.
///
/// Every call blocks the calling isolate.
abstract final class NativeDescriptorIo {
  /// The `EINTR` errno value.
  static const _eintr = 4;

  /// The loaded libc.
  static final DynamicLibrary _libc = _openLibc();

  /// libc's `free`, for finalizers of lists backed by memory from [allocate].
  static final Pointer<NativeFinalizerFunction> freeFinalizer = _libc
      .lookup<NativeFinalizerFunction>('free');

  static final _pread = _libc
      .lookupFunction<
        IntPtr Function(Int32, Pointer<Uint8>, Size, Int64),
        int Function(int, Pointer<Uint8>, int, int)
      >('pread64', isLeaf: true);

  static final _read = _libc
      .lookupFunction<
        IntPtr Function(Int32, Pointer<Uint8>, Size),
        int Function(int, Pointer<Uint8>, int)
      >('read', isLeaf: true);

  static final _close = _libc
      .lookupFunction<Int32 Function(Int32), int Function(int)>(
        'close',
        isLeaf: true,
      );

  static final _malloc = _libc
      .lookupFunction<
        Pointer<Uint8> Function(Size),
        Pointer<Uint8> Function(int)
      >('malloc', isLeaf: true);

  static final _free = _libc
      .lookupFunction<
        Void Function(Pointer<Uint8>),
        void Function(Pointer<Uint8>)
      >('free', isLeaf: true);

  static final _errno = _libc
      .lookupFunction<Pointer<Int32> Function(), Pointer<Int32> Function()>(
        '__errno',
        isLeaf: true,
      );

  /// Reads from [fd] at an offset, without changing the descriptor's
  /// position.
  ///
  /// Parameters:
  /// - [fd]: the descriptor to read.
  /// - [buffer]: the native buffer to read into.
  /// - [count]: the maximum number of bytes to read.
  /// - [offset]: the descriptor offset to read from.
  ///
  /// Returns: the number of bytes read; `0` at the end.
  ///
  /// Throws:
  /// - [OSError] if the read fails; `ESPIPE` if [fd] isn't seekable.
  ///
  /// Note:
  /// Retries when interrupted (`EINTR`).
  static int pread(int fd, Pointer<Uint8> buffer, int count, int offset) =>
      _retryInterrupted(() => _pread(fd, buffer, count, offset), 'pread64');

  /// Reads from [fd] at its position, and advances the position.
  ///
  /// Parameters:
  /// - [fd]: the descriptor to read.
  /// - [buffer]: the native buffer to read into.
  /// - [count]: the maximum number of bytes to read.
  ///
  /// Returns: the number of bytes read; `0` at the end.
  ///
  /// Throws:
  /// - [OSError] if the read fails.
  ///
  /// Note:
  /// Retries when interrupted (`EINTR`).
  static int read(int fd, Pointer<Uint8> buffer, int count) =>
      _retryInterrupted(() => _read(fd, buffer, count), 'read');

  /// Closes a descriptor, ignoring errors.
  ///
  /// Parameters:
  /// - [fd]: the descriptor to close.
  static void close(int fd) => _close(fd);

  /// Allocates native memory, to be released with [free].
  ///
  /// Parameters:
  /// - [size]: the number of bytes to allocate.
  ///
  /// Returns: a pointer to the allocated memory.
  ///
  /// Throws:
  /// - [OutOfMemoryError] if the allocation fails.
  static Pointer<Uint8> allocate(int size) {
    final pointer = _malloc(size);
    if (pointer == nullptr) {
      throw const OutOfMemoryError();
    }
    return pointer;
  }

  /// Frees native memory.
  ///
  /// Parameters:
  /// - [pointer]: memory returned by [allocate].
  static void free(Pointer<Uint8> pointer) => _free(pointer);

  /// Runs a libc call, retrying while it's interrupted (`EINTR`).
  ///
  /// Parameters:
  /// - [call]: the libc call; returns a negative value on failure.
  /// - [name]: the libc function's name, for the error message.
  ///
  /// Returns: the call's non-negative result.
  ///
  /// Throws:
  /// - [OSError] if the call fails with an error other than `EINTR`.
  static int _retryInterrupted(int Function() call, String name) {
    while (true) {
      final result = call();
      if (result >= 0) {
        return result;
      }
      final errno = _errno().value;
      if (errno != _eintr) {
        throw OSError('$name failed', errno);
      }
    }
  }

  /// Opens libc.
  ///
  /// Returns: the process itself when it exports `pread64`, otherwise
  /// `libc.so`.
  static DynamicLibrary _openLibc() {
    final process = DynamicLibrary.process();
    return process.providesSymbol('pread64')
        ? process
        : DynamicLibrary.open('libc.so');
  }
}
