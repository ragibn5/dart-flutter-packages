class DefaultClientConfig {
  /// The base URL.
  final String? baseUrl;

  /// Timeout for sending the request.
  final Duration? sendTimeout;

  /// Timeout for receiving the request.
  final Duration? receiveTimeout;

  /// Timeout for creating the connection.
  final Duration? connectionTimeout;

  /// Optional query parameters appended to the URL.
  ///
  /// Example: `{'page': 1, 'limit': 20}`
  final Map<String, dynamic> queryParameters;

  /// Additional headers to merge with the client-level headers.
  ///
  /// NOTE: These take precedence over client-level headers on collision.
  final Map<String, dynamic> headers;

  const DefaultClientConfig({
    this.baseUrl,
    this.sendTimeout,
    this.receiveTimeout,
    this.connectionTimeout,
    this.queryParameters = const {},
    this.headers = const {},
  });
}
