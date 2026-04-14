import 'package:dio/dio.dart';
import 'package:net_kit/src/services/response_classifier.dart';
import 'package:test/test.dart';

void main() {
  const sut = DefaultResponseClassifier();
  final requestOptions = RequestOptions();

  test('Status code below 400 returns false', () {
    final response = Response<dynamic>(
      requestOptions: requestOptions,
      statusCode: 399,
    );

    expect(sut.isError(response), isFalse);
  });

  test('Status code 400 or above returns true', () {
    final response = Response<dynamic>(
      requestOptions: requestOptions,
      statusCode: 400,
    );

    expect(sut.isError(response), isTrue);
  });

  test('Null status code returns false', () {
    final response = Response<dynamic>(
      requestOptions: requestOptions,
    );

    expect(sut.isError(response), isFalse);
  });
}
