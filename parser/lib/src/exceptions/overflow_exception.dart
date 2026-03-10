class OverflowException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  OverflowException(
    this.message, {
    this.stackTrace,
  });

  @override
  String toString() {
    return '$OverflowException: $message';
  }
}
