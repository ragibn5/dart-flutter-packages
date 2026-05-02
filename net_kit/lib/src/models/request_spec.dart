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

  /// The base URL.
  final String? baseUrl;

  /// Timeout for sending the request.
  final Duration? sendTimeout;

  /// Timeout for receiving the request.
  final Duration? receiveTimeout;

  /// Timeout for the connection.
  final Duration? connectionTimeout;

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
    this.baseUrl,
    this.sendTimeout,
    this.receiveTimeout,
    this.connectionTimeout,
    this.followRedirects,
    this.maxRedirects,
  });

  RequestSpec copyWith({
    String? pathOrUrl,
    HttpMethod? method,
    RequestBody? body,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    String? contentType,
    String? baseUrl,
    Duration? sendTimeout,
    Duration? receiveTimeout,
    Duration? connectionTimeout,
    bool? followRedirects,
    int? maxRedirects,
  }) {
    return RequestSpec(
      pathOrUrl: pathOrUrl ?? this.pathOrUrl,
      method: method ?? this.method,
      body: body ?? this.body,
      queryParameters: queryParameters ?? this.queryParameters,
      headers: headers ?? this.headers,
      contentType: contentType ?? this.contentType,
      baseUrl: baseUrl ?? this.baseUrl,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      followRedirects: followRedirects ?? this.followRedirects,
      maxRedirects: maxRedirects ?? this.maxRedirects,
    );
  }
}
