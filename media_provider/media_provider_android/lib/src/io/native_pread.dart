import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

/// Experimental: libc's `pread64` over FFI, for reading a descriptor the
/// platform side holds open, without reopening the file.
abstract final class NativePread {
  static const _eintr = 4;

  static final DynamicLibrary _libc = _openLibc();

  static final _pread = _libc
      .lookupFunction<
        IntPtr Function(Int32, Pointer<Uint8>, Size, Int64),
        int Function(int, Pointer<Uint8>, int, int)
      >('pread64', isLeaf: true);

  static final _malloc = _libc
      .lookupFunction<
        Pointer<Uint8> Function(Size),
        Pointer<Uint8> Function(int)
      >('malloc', isLeaf: true);

  static final Pointer<NativeFinalizerFunction> _free = _libc.lookup('free');

  static final _errno = _libc
      .lookupFunction<Pointer<Int32> Function(), Pointer<Int32> Function()>(
        '__errno',
        isLeaf: true,
      );

  static DynamicLibrary _openLibc() {
    final process = DynamicLibrary.process();
    return process.providesSymbol('pread64')
        ? process
        : DynamicLibrary.open('libc.so');
  }

  /// Reads up to [length] bytes of [fd] at [offset], without moving the
  /// descriptor's position.
  ///
  /// The bytes are read straight into native memory that the returned list
  /// views, so there is no copy; it is freed once the list is unreachable.
  /// An empty list means [offset] is at or past the end. Blocks the calling
  /// isolate for the duration of the read.
  static Uint8List read(int fd, int length, int offset) {
    final pointer = _malloc(max(length, 1));
    if (pointer == nullptr) {
      throw const OutOfMemoryError();
    }
    final bytes = pointer.asTypedList(length, finalizer: _free);

    while (true) {
      final count = _pread(fd, pointer, length, offset);
      if (count >= 0) {
        return count == length ? bytes : Uint8List.sublistView(bytes, 0, count);
      }
      final errno = _errno().value;
      if (errno != _eintr) {
        throw OSError('pread64 failed on fd $fd at $offset', errno);
      }
    }
  }
}
