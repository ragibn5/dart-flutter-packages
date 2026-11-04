import 'dart:async';
import 'dart:typed_data';

import 'package:media_provider_android/src/io/source/media_byte_source.dart';

/// A [MediaByteSource] that serves scripted pieces, one per read.
final class FakeByteSource extends MediaByteSource {
  /// The pieces still to serve; an empty read follows the last one.
  final List<Uint8List> _pieces;

  /// Thrown by the next read instead of serving a piece, when set.
  Exception? readError;

  /// When set, [readAll] waits for it before answering.
  Completer<void>? readAllGate;

  /// The `maxLength` of each [read] call, in order.
  final readLengths = <int>[];

  /// The number of [close] calls.
  int closeCount = 0;

  @override
  final String id;

  @override
  final int? length;

  @override
  bool get isSeekable => true;

  FakeByteSource({
    this.id = 'fake-1',
    this.length,
    List<List<int>> pieces = const [],
  }) : _pieces = [for (final piece in pieces) Uint8List.fromList(piece)];

  @override
  Future<Uint8List> read(int maxLength, {int? position}) async {
    readLengths.add(maxLength);
    final error = readError;
    if (error != null) {
      throw error;
    }
    return _pieces.isEmpty ? Uint8List(0) : _pieces.removeAt(0);
  }

  @override
  Future<Uint8List> readAll({int? position}) async {
    await readAllGate?.future;
    final error = readError;
    if (error != null) {
      throw error;
    }
    return readToEnd(1024);
  }

  @override
  Future<void> close() async => closeCount++;

  /// Exposes [readToEnd] to tests.
  Future<Uint8List> callReadToEnd(int pieceSize) => readToEnd(pieceSize);
}
