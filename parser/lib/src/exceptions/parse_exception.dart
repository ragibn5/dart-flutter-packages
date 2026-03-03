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
    // ignore: no_runtimeType_toString
    return '\n*** $runtimeType ***\n'
        'Message:\n$message\n'
        'Source exception: \n$sourceException\n';
  }
}
