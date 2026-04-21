import 'package:net_kit/src/models/response_context.dart';
import 'package:net_kit/src/services/response_classifier.dart';
import 'package:test/test.dart';

void main() {
  const sut = DefaultResponseClassifier();

  test('Status code below 400 returns false', () {
    final response = ResponseContext(
      statusCode: 399,
      responseHeaders: {},
      responseBody: null,
    );

    expect(sut.isError(response), isFalse);
  });

  test('Status code 400 or above returns true', () {
    final response = ResponseContext(
      statusCode: 400,
      responseHeaders: {},
      responseBody: null,
    );

    expect(sut.isError(response), isTrue);
  });

  test('Status code 0 returns false', () {
    final response = ResponseContext(
      statusCode: 0,
      responseHeaders: {},
      responseBody: null,
    );

    expect(sut.isError(response), isFalse);
  });
}
