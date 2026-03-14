class ParseException implements Exception {
  final String message;
  final dynamic sourceException;
  final StackTrace? sourceExceptionStackTrace;

  ParseException(
    this.message, {
    this.sourceException,
    this.sourceExceptionStackTrace,
  });

  @override
  String toString() {
    return '$ParseException: $message';
  }
}
