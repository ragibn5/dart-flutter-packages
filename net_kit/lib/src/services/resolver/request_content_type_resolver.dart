import 'package:net_kit/src/models/request_body.dart';

abstract interface class RequestContentTypeResolver {
  String? resolve(RequestBody? body);
}

class DefaultRequestContentTypeResolver implements RequestContentTypeResolver {
  const DefaultRequestContentTypeResolver();

  @override
  String? resolve(RequestBody? body) {
    return switch (body) {
      RawBody(contentType: final contentType) => contentType,
      JsonBody() => 'application/json',
      FormUrlEncodedBody() => 'application/x-www-form-urlencoded',
      MultipartBody() => 'multipart/form-data',
      null => null,
    };
  }
}
