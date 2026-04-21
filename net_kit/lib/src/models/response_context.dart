import 'package:net_kit/src/models/request_metadata.dart';

class ResponseContext {
  /// The status code from the server side.
  final int statusCode;

  /// The raw response body before decoding.
  final dynamic rawResponseBody;

  /// The response headers.
  final Map<String, List<String>> responseHeaders;

  /// The request metadata that initiated the corresponding request.
  final RequestMetadata requestMetadata;

  ResponseContext({
    required this.statusCode,
    required this.rawResponseBody,
    required this.responseHeaders,
    required this.requestMetadata,
  });
}
