// ignore_for_file: avoid_init_to_null

import 'package:net_kit/src/enums/http_method.dart';

class RequestSpec<RequestBodyType> {
  /// The endpoint path, relative to the base URL.
  ///
  /// Example: `'/users/42'`
  final String path;

  /// The HTTP method to use for this request.
  final HttpMethod method;

  /// Optional query parameters appended to the URL.
  ///
  /// Example: `{'page': 1, 'limit': 20}`
  final Map<String, dynamic>? queryParameters;

  /// Additional headers to merge with the client-level headers.
  ///
  /// NOTE: These take precedence over client-level headers on collision.
  final Map<String, dynamic>? headers;

  /// The request body to encode and send.
  ///
  /// NOTE: Pass `null` for requests with no body.
  final RequestBodyType body;

  RequestSpec({
    required this.path,
    required this.method,
    required this.body,
    this.queryParameters = null,
    this.headers = null,
  });
}
