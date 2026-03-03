import 'dart:collection';

extension QueueExtension<T> on Queue<T> {
  /// Returns a new queue with elements replaced based on a test function
  Queue<T> replaceWhere(
    bool Function(T e) test, {
    required T Function(T old) replacement,
  }) {
    return Queue.of(map((e) => test(e) ? replacement(e) : e));
  }
}
