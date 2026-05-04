import 'package:dio/dio.dart';
import 'package:net_kit/src/models/raw_data.dart';
import 'package:net_kit/src/models/request_body.dart';
import 'package:net_kit/src/services/resolver/request_content_type_resolver.dart';
import 'package:test/test.dart';

void main() {
  const sut = DefaultRequestContentTypeResolver();

  test('Null bodies do not infer a content type', () {
    expect(sut.resolve(null), isNull);
  });

  test('Raw bodies use the explicit raw content type', () {
    expect(
      sut.resolve(
        const RawBody(
          RawBytes([1, 2, 3]),
          contentType: 'application/octet-stream',
        ),
      ),
      'application/octet-stream',
    );
  });

  test('Json bodies infer application/json', () {
    expect(
      sut.resolve(const JsonBody({'name': 'net_kit'})),
      Headers.jsonContentType,
    );
  });

  test('Form bodies infer application/x-www-form-urlencoded', () {
    expect(
      sut.resolve(const FormUrlEncodedBody(fields: {'name': 'net_kit'})),
      Headers.formUrlEncodedContentType,
    );
  });

  test('Multipart bodies infer multipart/form-data', () {
    expect(
      sut.resolve(const MultipartBody()),
      Headers.multipartFormDataContentType,
    );
  });
}
