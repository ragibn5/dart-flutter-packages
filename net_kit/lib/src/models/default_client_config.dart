class DefaultClientConfig {
  /// The base URL.
  final String? baseUrl;

  /// Default request timeout.
  final Duration? sendTimeout;

  /// Default receive timeout.
  final Duration? receiveTimeout;

  /// Default connection timeout.
  final Duration? connectionTimeout;

  /// Default list of query params.
  final Map<String, dynamic>? queryParameters;

  /// Default list of query params.
  final Map<String, dynamic>? headers;

  /// Whether to follow redirects.
  ///
  /// Defaults to true.
  final bool followRedirects;

  /// Maximum number of redirects to follow.
  ///
  /// Defaults to 5.
  final int maxRedirects;

  const DefaultClientConfig({
    this.baseUrl,
    this.sendTimeout,
    this.receiveTimeout,
    this.connectionTimeout,
    this.queryParameters,
    this.headers,
    this.followRedirects = true,
    this.maxRedirects = 5,
  });
}
