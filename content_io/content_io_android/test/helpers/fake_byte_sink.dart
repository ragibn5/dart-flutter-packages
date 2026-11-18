import 'dart:async';
import 'dart:typed_data';

import 'package:content_io_android/src/io/sink/content_byte_sink.dart';

/// A [ContentByteSink] that records what it's given.
final class FakeByteSink extends ContentByteSink {
  /// The bytes of each [write] call, in order.
  final writes = <Uint8List>[];

  /// Thrown by the next [write] instead of recording it, when set.
  Exception? writeError;

  /// Thrown by [close], when set.
  Exception? closeError;

  /// When set, [write] waits for it before recording.
  Completer<void>? writeGate;

  /// The number of [close] calls.
  int closeCount = 0;

  /// The number of [abort] calls.
  int abortCount = 0;

  @override
  final String id;

  FakeByteSink({this.id = 'sink-1'});

  @override
  Future<void> write(Uint8List bytes) async {
    await writeGate?.future;
    final error = writeError;
    if (error != null) {
      throw error;
    }
    writes.add(bytes);
  }

  @override
  Future<void> close() async {
    closeCount++;
    final error = closeError;
    if (error != null) {
      throw error;
    }
  }

  @override
  Future<void> abort() async {
    abortCount++;
  }
}
