class OverflowException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  OverflowException(
    this.message, {
    this.stackTrace,
  });

  @override
  String toString() {
    // ignore: no_runtimeType_toString
    return '\n*** $runtimeType ***\n$message';
  }
}
