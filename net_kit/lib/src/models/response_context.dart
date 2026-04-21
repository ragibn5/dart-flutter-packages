class ResponseContext {
  /// The status code from the server side.
  final int statusCode;

  /// The raw response body before decoding.
  final dynamic responseBody;

  /// The response headers.
  final Map<String, List<String>> responseHeaders;

  ResponseContext({
    required this.statusCode,
    required this.responseBody,
    required this.responseHeaders,
  });
}
