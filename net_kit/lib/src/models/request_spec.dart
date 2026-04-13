// ignore_for_file: avoid_init_to_null

import 'package:net_kit/src/models/http_method.dart';
import 'package:net_kit/src/services/request_codec.dart';
import 'package:net_kit/src/services/response_classifier.dart';

class RequestSpec<Req, Res, Err> {
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
  final Req body;

  /// The request codec to use for this request.
  final RequestCodec<Req, Res, Err> codec;

  /// The response classifier to use for this request.
  final ResponseClassifier responseClassifier;

  RequestSpec({
    required this.path,
    required this.method,
    required this.codec,
    required this.body,
    this.responseClassifier = const DefaultResponseClassifier(),
    this.queryParameters = null,
    this.headers = null,
  });
}
