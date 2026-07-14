extension ListExtension<T> on List<T> {
  /// Returns a new list with elements replaced based on a test function
  List<T> replaceWhere(
    bool Function(T e) test, {
    required T Function(T old) replacement,
  }) {
    return List.of(map((e) => test(e) ? replacement(e) : e));
  }
}
