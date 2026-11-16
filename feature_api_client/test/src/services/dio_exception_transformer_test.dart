import 'package:dio/dio.dart';
import 'package:feature_api_client/feature_api_client.dart';
import 'package:net_models/net_models.dart';
import 'package:test/test.dart';

void main() {
  const sut = DioExceptionTransformer();
  final request = RequestOptions(baseUrl: 'https://example.com', path: '/a');

  test('transformShouldReturnTheTransportErrorIfTheTransportFailed', () {
    const expected = {
      DioExceptionType.connectionTimeout: TransportErrorType.CONNECTION_TIMEOUT,
      DioExceptionType.sendTimeout: TransportErrorType.SEND_TIMEOUT,
      DioExceptionType.receiveTimeout: TransportErrorType.RECEIVE_TIMEOUT,
      DioExceptionType.connectionError: TransportErrorType.CONNECTION_ERROR,
      DioExceptionType.badCertificate: TransportErrorType.BAD_CERTIFICATE,
    };

    for (final MapEntry(key: type, value: errorType) in expected.entries) {
      final error = sut.transformApiError(
        DioException(requestOptions: request, type: type),
      );

      expect(error, isA<TransportError>(), reason: '$type');
      expect((error as TransportError).type, errorType, reason: '$type');
    }
  });

  test('transformShouldReturnCancellationWithTheReasonIfCancelled', () {
    final error = sut.transformApiError(
      DioException(
        requestOptions: request,
        type: DioExceptionType.cancel,
        error: 'session lost',
      ),
    );

    expect(error, isA<CancellationError>());
    final cancellation = error as CancellationError;
    expect(cancellation.source, 'GET https://example.com/a');
    expect(cancellation.message, 'session lost');
  });

  test('transformShouldReturnCancellationWithTheMessageIfThereIsNoReason', () {
    final error = sut.transformApiError(
      DioException(
        requestOptions: request,
        type: DioExceptionType.cancel,
        message: 'cancelled',
      ),
    );

    expect((error as CancellationError).message, 'cancelled');
  });

  test('transformShouldReturnUnexpectedWithTheCauseIfAnythingElseFailed', () {
    final cause = Exception('failed');
    final stackTrace = StackTrace.current;

    final error = sut.transformApiError(
      DioException(
        requestOptions: request,
        error: cause,
        stackTrace: stackTrace,
      ),
    );

    expect(error, isA<UnexpectedError>());
    expect((error as UnexpectedError).cause, cause);
    expect(error.stackTrace, stackTrace);
  });

  test('transformShouldReturnUnexpectedWithTheExceptionIfThereIsNoCause', () {
    final exception = DioException(
      requestOptions: request,
      type: DioExceptionType.badResponse,
    );

    final error = sut.transformApiError(exception);

    expect((error as UnexpectedError).cause, exception);
  });
}
