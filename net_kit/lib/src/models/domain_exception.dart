/// A failure indicating an domain specific error returned by the server.
class DomainException<E> {
  /// The HTTP status code from the server.
  final int statusCode;

  /// The decoded, domain-typed error from the server.
  final E error;

  /// The response headers.
  final Map<String, List<String>> headers;

  /// The cause of the exception.
  final Object? cause;

  /// The stack trace of the exception.
  final StackTrace? stackTrace;

  const DomainException({
    required this.statusCode,
    required this.error,
    required this.headers,
    this.cause,
    this.stackTrace,
  });

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'DomainException{statusCode: $statusCode, headers: $headers, error: $error, cause: $cause, stackTrace: $stackTrace}';
  }
}
