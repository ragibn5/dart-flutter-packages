/// A failure indicating an domain specific error returned by the server.
class ErrorResponseData<E> {
  /// The HTTP status code from the server.
  final int statusCode;

  /// The decoded, domain-typed error from the server.
  final E error;

  /// The response headers.
  final Map<String, List<String>> headers;

  const ErrorResponseData({
    required this.statusCode,
    required this.error,
    required this.headers,
  });

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'ErrorResponseData {statusCode: $statusCode, headers: $headers, error: $error}';
  }
}
