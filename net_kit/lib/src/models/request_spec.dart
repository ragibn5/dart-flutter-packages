// ignore_for_file: avoid_init_to_null

import 'package:net_kit/src/enums/http_method.dart';
import 'package:net_kit/src/models/request_body.dart';

class RequestSpec {
  /// The endpoint path, relative to the base URL.
  final String pathOrUrl;

  /// The HTTP method to use for this request.
  final HttpMethod method;

  /// The request body to send.
  ///
  /// NOTE: Pass `null` for requests with no body.
  final RequestBody? body;

  /// Optional query parameters appended to the URL.
  final Map<String, dynamic>? queryParameters;

  /// Additional headers to merge with the client-level headers.
  final Map<String, dynamic>? headers;

  /// Explicit content type for this request body.
  ///
  /// If null, it may be inferred from the [body] field above.
  final String? contentType;

  /// Timeout for sending the request.
  final Duration? sendTimeout;

  /// Timeout for receiving the request.
  final Duration? receiveTimeout;

  /// Whether to follow redirects.
  final bool? followRedirects;

  /// Maximum number of redirects to follow.
  final int? maxRedirects;

  RequestSpec({
    required this.pathOrUrl,
    required this.method,
    this.body,
    this.queryParameters,
    this.headers,
    this.contentType,
    this.sendTimeout,
    this.receiveTimeout,
    this.followRedirects,
    this.maxRedirects,
  });
}
