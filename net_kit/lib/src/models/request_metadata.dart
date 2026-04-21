import 'package:net_kit/src/enums/http_method.dart';

class RequestMetadata {
  /// The endpoint path, relative to the base URL.
  ///
  /// Example: `'/users/42'`
  final String path;

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

  RequestMetadata({
    required this.path,
    required this.method,
    required this.queryParameters,
    required this.headers,
  });
}
