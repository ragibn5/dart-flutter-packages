import 'package:net_kit/src/enums/http_method.dart';

class RequestMetadata {
  /// The endpoint path, relative to the base URL.
  final String pathOrUrl;

  /// The HTTP method to use for this request.
  final HttpMethod method;

  /// Optional query parameters appended to the URL.
  final Map<String, dynamic>? queryParameters;

  /// Additional headers to merge with the client-level headers.
  final Map<String, dynamic>? headers;

  /// Timeout for sending the request.
  final Duration? sendTimeout;

  /// Timeout for receiving the request.
  final Duration? receiveTimeout;

  /// Whether to follow redirects.
  final bool? followRedirects;

  /// Maximum number of redirects to follow.
  final int? maxRedirects;

  RequestMetadata({
    required this.pathOrUrl,
    required this.method,
    this.queryParameters,
    this.headers,
    this.sendTimeout,
    this.receiveTimeout,
    this.followRedirects,
    this.maxRedirects,
  });
}
