import 'package:net_kit/src/models/request_spec.dart';

class RawResponse {
  /// The status code from the server side.
  final int statusCode;

  /// The raw response body before decoding.
  final dynamic rawResponseBody;

  /// The response headers.
  final Map<String, List<String>> responseHeaders;

  /// The original request.
  final RequestSpec request;

  const RawResponse({
    required this.statusCode,
    required this.rawResponseBody,
    required this.responseHeaders,
    required this.request,
  });
}
