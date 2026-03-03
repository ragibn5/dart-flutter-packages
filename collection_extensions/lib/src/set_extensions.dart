extension SetExtension<T> on Set<T> {
  /// Returns a new set with elements replaced based on a test function
  Set<T> replaceWhere(
    bool Function(T e) test, {
    required T Function(T old) replacement,
  }) {
    return Set.of(map((e) => test(e) ? replacement(e) : e));
  }
}
