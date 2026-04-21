// ignore_for_file: avoid_init_to_null

import 'package:net_kit/src/models/request_metadata.dart';

class RequestSpec<RequestBodyType> extends RequestMetadata {
  /// The request body to encode and send.
  ///
  /// NOTE: Pass `null` for requests with no body.
  final RequestBodyType body;

  RequestSpec({
    required super.path,
    required super.method,
    super.queryParameters = const {},
    super.headers = const {},
    required this.body,
  });
}
