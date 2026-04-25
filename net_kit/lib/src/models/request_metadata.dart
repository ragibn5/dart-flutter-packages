import 'package:net_kit/src/enums/http_method.dart';

class RequestMetadata {
  /// The endpoint path, relative to the base URL.
  ///
  /// Example: `'/users/42'`
  final String pathOrUrl;

  /// The HTTP method to use for this request.
  final HttpMethod method;

  /// Optional query parameters appended to the URL.
  ///
  /// Example: `{'page': 1, 'limit': 20}`
  final Map<String, dynamic> queryParameters;

  /// Additional headers to merge with the client-level headers.
  ///
  /// NOTE: These take precedence over client-level headers on collision.
  final Map<String, dynamic> headers;

  /// Timeout for sending the request.
  final Duration? sendTimeout;

  /// Timeout for receiving the request.
  final Duration? receiveTimeout;

  RequestMetadata({
    required this.pathOrUrl,
    required this.method,
    this.queryParameters = const {},
    this.headers = const {},
    this.sendTimeout,
    this.receiveTimeout,
  });
}
