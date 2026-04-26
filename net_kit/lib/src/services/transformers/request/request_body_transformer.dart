import 'package:net_kit/src/models/request_body.dart';

abstract interface class RequestBodyTransformer {
  dynamic transform(RequestBody? body);
}
