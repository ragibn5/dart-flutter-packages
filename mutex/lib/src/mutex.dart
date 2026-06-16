import 'dart:async';

/// A lightweight mutex for simple locking.
///
/// Each [synchronized] call waits for all previous calls on the same
/// instance to complete before executing.
///
/// ```dart
/// final mutex = Mutex();
///
/// Future<void> write(String data) async {
///   await mutex.synchronized(() => file.writeAsString(data));
/// }
/// ```
class Mutex {
  Future<void>? _last;

  /// Runs [fn] after all previously synchronized calls have completed.
  Future<T> synchronized<T>(Future<T> Function() fn) async {
    final prev = _last ?? Future<void>.value();
    final completer = Completer<void>.sync();
    _last = completer.future;
    await prev;
    try {
      return await fn();
    } finally {
      completer.complete();
    }
  }
}
