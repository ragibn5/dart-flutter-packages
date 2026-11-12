import 'package:app_logger/app_logger.dart';
import 'package:app_template/features/app/infrastructure/network/interceptors/logger_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers/fake_http_client_adapter.dart';

class _MockAppLogger extends Mock implements AppLogger {}

void main() {
  late _MockAppLogger mockLogger;

  setUp(() {
    mockLogger = _MockAppLogger();
  });

  Dio build(ResponseBody Function(RequestOptions) respond) => fakeDio(
    FakeHttpClientAdapter(respond),
    interceptors: [LoggerInterceptor(mockLogger)],
  );

  List<Map<String, dynamic>> loggedInfoExtras() => verify(
    () => mockLogger.logInfo(
      tag: LoggerInterceptor.TAG,
      message: any(named: 'message'),
      extras: captureAny(named: 'extras'),
    ),
  ).captured.cast<Map<String, dynamic>>();

  test('requestAndResponseShouldBeLoggedIfTheRequestSucceeds', () async {
    final response = await build(
      (_) => ResponseBody.fromString('pong', 200),
    ).post<dynamic>('/ping', data: 'ping');

    expect(response.data, 'pong');
    final [request, answer] = loggedInfoExtras();
    expect(request['method'], 'POST');
    expect(request['uri'], 'https://abc.com/ping');
    expect(request['data'], 'ping');
    expect(answer['statusCode'], 200);
    expect(answer['data'], 'pong');
  });

  test('errorShouldBeLoggedAndPassedOnIfTheRequestFails', () async {
    final cause = Exception('offline');
    final dio = build(
      (o) => throw DioException.connectionError(
        requestOptions: o,
        reason: 'offline',
        error: cause,
      ),
    );

    await expectLater(
      dio.get<dynamic>('/ping'),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.connectionError,
        ),
      ),
    );

    final extras =
        verify(
              () => mockLogger.logError(
                tag: LoggerInterceptor.TAG,
                message: any(named: 'message'),
                error: cause,
                stackTrace: any(named: 'stackTrace'),
                extras: captureAny(named: 'extras'),
              ),
            ).captured.single
            as Map<String, dynamic>;
    expect(extras['type'], 'connectionError');
    expect(extras.containsKey('response'), isFalse);
  });

  test('errorShouldBeLoggedWithTheResponseIfTheServerAnswersAnError', () async {
    final dio = build((_) => ResponseBody.fromString('missing', 404));

    await expectLater(dio.get<dynamic>('/ping'), throwsA(isA<DioException>()));

    final extras =
        verify(
              () => mockLogger.logError(
                tag: LoggerInterceptor.TAG,
                message: any(named: 'message'),
                error: any(named: 'error'),
                stackTrace: any(named: 'stackTrace'),
                extras: captureAny(named: 'extras'),
              ),
            ).captured.single
            as Map<String, dynamic>;
    final response = extras['response'] as Map<String, dynamic>;
    expect(response['statusCode'], 404);
    expect(response['data'], 'missing');
  });
}
