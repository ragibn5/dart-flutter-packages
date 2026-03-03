// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:app_template/shared/logger/app_logger.dart';
import 'package:app_template/shared/network/interceptors/logger_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAppLogger extends Mock implements AppLogger {}

class _MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class _MockResponseInterceptorHandler extends Mock
    implements ResponseInterceptorHandler {}

class _MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  final requestOptions = RequestOptions(
    baseUrl: 'https://abc.com',
    path: '/ping',
    data: {'1': 1, 's': 'a-string'},
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    queryParameters: {'1': 1},
  );
  final response = Response<dynamic>(
    requestOptions: requestOptions,
    data: {'i': 100, 's': 'another-string'},
    statusCode: HttpStatus.ok,
    headers: Headers()..add(HttpHeaders.contentTypeHeader, 'application/json'),
  );
  final exception = DioException(
    type: DioExceptionType.badResponse,
    requestOptions: requestOptions,
    response: response,
  );

  late _MockAppLogger mockAppLogger;
  late _MockRequestInterceptorHandler mockRequestInterceptorHandler;
  late _MockResponseInterceptorHandler mockResponseInterceptorHandler;
  late _MockErrorInterceptorHandler mockErrorInterceptorHandler;

  late LoggerInterceptor loggerInterceptor;

  setUpAll(() {
    registerFallbackValue(requestOptions);
    registerFallbackValue(response);
    registerFallbackValue(exception);
  });

  setUp(() {
    mockAppLogger = _MockAppLogger();

    mockRequestInterceptorHandler = _MockRequestInterceptorHandler();
    mockResponseInterceptorHandler = _MockResponseInterceptorHandler();
    mockErrorInterceptorHandler = _MockErrorInterceptorHandler();

    loggerInterceptor = LoggerInterceptor(mockAppLogger);

    when(
      () => mockAppLogger.logDebug(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
        extras: any(named: 'extras'),
      ),
    ).thenAnswer((_) => {});
    when(
      () => mockAppLogger.logInfo(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
        extras: any(named: 'extras'),
      ),
    ).thenAnswer((_) => {});
    when(
      () => mockAppLogger.logWarning(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
        extras: any(named: 'extras'),
      ),
    ).thenAnswer((_) => {});
    when(
      () => mockAppLogger.logError(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
        extras: any(named: 'extras'),
      ),
    ).thenAnswer((_) => {});

    when(
      () => mockRequestInterceptorHandler.next(requestOptions),
    ).thenAnswer((_) {});
    when(
      () => mockResponseInterceptorHandler.next(response),
    ).thenAnswer((_) {});
    when(() => mockErrorInterceptorHandler.next(exception)).thenAnswer((_) {});
  });

  test(
    'Should log on request and propagate the request to next interceptor',
    () {
      loggerInterceptor.onRequest(
        requestOptions,
        mockRequestInterceptorHandler,
      );

      verifyInOrder([
        () => mockAppLogger.logInfo(
          tag: LoggerInterceptor.TAG,
          message: any(named: 'message'),
          extras: any(named: 'extras'),
        ),
        () => mockRequestInterceptorHandler.next(requestOptions),
      ]);
    },
  );

  test(
    'Should log on response and propagate the response to next interceptor',
    () {
      loggerInterceptor.onResponse(response, mockResponseInterceptorHandler);

      verifyInOrder([
        () => mockAppLogger.logInfo(
          tag: LoggerInterceptor.TAG,
          message: any(named: 'message'),
          extras: any(named: 'extras'),
        ),
        () => mockResponseInterceptorHandler.next(response),
      ]);
    },
  );

  test('Should log on error and propagate the error to next interceptor', () {
    loggerInterceptor.onError(exception, mockErrorInterceptorHandler);

    verifyInOrder([
      () => mockAppLogger.logError(
        tag: LoggerInterceptor.TAG,
        message: any(named: 'message'),
        stackTrace: any(named: 'stackTrace'),
        extras: any(named: 'extras'),
      ),
      () => mockErrorInterceptorHandler.next(exception),
    ]);
  });
}
