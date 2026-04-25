import 'package:net_kit/src/enums/http_method.dart';
import 'package:net_kit/src/models/request_metadata.dart';
import 'package:net_kit/src/models/response_context.dart';
import 'package:net_kit/src/services/mappers/response_classifier.dart';
import 'package:test/test.dart';

void main() {
  const sut = DefaultResponseClassifier();

  final requestMetadata = RequestMetadata(
    pathOrUrl: '/users',
    method: HttpMethod.GET,
  );

  test('Status code below 400 returns false', () {
    final response = ResponseContext(
      statusCode: 399,
      responseHeaders: {},
      rawResponseBody: null,
      requestMetadata: requestMetadata,
    );

    expect(sut.isError(response), isFalse);
  });

  test('Status code 400 or above returns true', () {
    final response = ResponseContext(
      statusCode: 400,
      responseHeaders: {},
      rawResponseBody: null,
      requestMetadata: requestMetadata,
    );

    expect(sut.isError(response), isTrue);
  });

  test('Status code 0 returns false', () {
    final response = ResponseContext(
      statusCode: 0,
      responseHeaders: {},
      rawResponseBody: null,
      requestMetadata: requestMetadata,
    );

    expect(sut.isError(response), isFalse);
  });
}
