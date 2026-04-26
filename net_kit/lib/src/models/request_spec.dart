// ignore_for_file: avoid_init_to_null

import 'package:net_kit/src/models/request_metadata.dart';

class RequestSpec<RequestBodyType> extends RequestMetadata {
  /// The request body to encode and send.
  ///
  /// NOTE: Pass `null` for requests with no body.
  final RequestBodyType body;

  RequestSpec({
    required super.pathOrUrl,
    required super.method,
    super.queryParameters,
    super.headers,
    super.sendTimeout,
    super.receiveTimeout,
    super.followRedirects,
    super.maxRedirects,
    required this.body,
  });
}
