import 'dart:async';

import 'package:meta/meta.dart';

/// A [StreamController] wrapper to hold the last data added to the stream.
class CachedStreamController<T> {
  T? _lastItem;
  final StreamController<T> _controller;

  @visibleForTesting
  CachedStreamController.test(StreamController<T> controller)
      : _controller = controller;

  /// Create a single subscriber [CachedStreamController]
  CachedStreamController.single() : this._(StreamController<T>());

  /// Create a broadcast subscriber [CachedStreamController]
  CachedStreamController.broadcast() : this._(StreamController<T>.broadcast());

  /// Create a [CachedStreamController] from an explicit
  /// [StreamController] instance.
  CachedStreamController._(StreamController<T> controller)
      : _controller = controller;

  /// Add an item to the stream
  void add(T item) {
    _lastItem = item;
    _controller.add(item);
  }

  /// Get the last item of this stream
  T? get lastItem => _lastItem;

  /// Expose the stream for listening
  Stream<T> get stream => _controller.stream;

  /// Close the stream
  void close() => _controller.close();
}
