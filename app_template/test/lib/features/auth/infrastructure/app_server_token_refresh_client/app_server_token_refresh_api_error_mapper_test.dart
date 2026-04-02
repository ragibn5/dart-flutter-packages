// ignore_for_file: cascade_invocations
// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:app_template/core/models/server_message.dart';
import 'package:app_template/features/auth/infrastructure/app_server_token_refresh_client/app_server_token_refresh_api_error_mapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sampleServerMessage = ServerMessage(code: 'test', message: 'test');

  final requestOptions = RequestOptions();
  final stackTrace = StackTrace.current;

  late AppServerTokenRefreshApiErrorMapper sut;

  void expectDioTypeMapsToAppError({
    required AppServerTokenRefreshApiErrorMapper mapper,
    required RequestOptions requestOptions,
    required StackTrace stackTrace,
    required DioExceptionType type,
  }) {
    final exception = DioException(
      requestOptions: requestOptions,
      type: type,
      stackTrace: stackTrace,
    );

    final result = mapper.mapError(exception, stackTrace);
    result.fold(
      (appError) {
        expect(appError, isNotNull);
        expect(appError.exception, exception.error);
        expect(appError.stackTrace, stackTrace);
      },
      (networkError) => expect(networkError, isNull),
      (serverError) => expect(serverError, isNull),
    );
  }

  void expectDioTypeMapsToNetworkError({
    required AppServerTokenRefreshApiErrorMapper mapper,
    required RequestOptions requestOptions,
    required StackTrace stackTrace,
    required DioExceptionType type,
  }) {
    final exception = DioException(
      requestOptions: requestOptions,
      type: type,
      stackTrace: stackTrace,
    );

    final result = mapper.mapError(exception, stackTrace);
    result.fold(
      (appError) => expect(appError, isNull),
      (networkError) {
        expect(networkError, isNotNull);
        expect(networkError.exception, exception.error);
        expect(networkError.stackTrace, stackTrace);
      },
      (serverError) => expect(serverError, isNull),
    );
  }

  setUp(() {
    sut = AppServerTokenRefreshApiErrorMapper();
  });

  test(
    'If exception IS NOT of type `DioException` then should map to application error',
    () {
      final stackTrace = StackTrace.current;
      final exception = Exception('Test exception');

      final result = sut.mapError(exception, stackTrace);
      result.fold(
        (appError) {
          expect(appError, isNotNull);
          expect(appError.message, isNotEmpty);
          expect(appError.exception, exception);
          expect(appError.stackTrace, stackTrace);
        },
        (networkError) => expect(networkError, isNull),
        (serverError) => expect(serverError, isNull),
      );
    },
  );

  test(
    'If exception IS of type `DioException` and it has a valid response data then should map to server error',
    () {
      const statusCode = HttpStatus.badRequest;
      final exception = DioException(
        requestOptions: requestOptions,
        response: Response(
          statusCode: statusCode,
          requestOptions: requestOptions,
          data: sampleServerMessage.toJson(),
        ),
      );

      final result = sut.mapError(exception, stackTrace);
      result.fold(
        (appError) => expect(appError, isNull),
        (networkError) => expect(networkError, isNull),
        (serverError) {
          expect(serverError, isNotNull);
          expect(serverError.statusCode, statusCode);
          expect(serverError.errorResponse, sampleServerMessage);
        },
      );
    },
  );

  test(
    'DioException with NO response data and type unknown/cancel maps to app error',
    () {
      final appErrorTypes = [DioExceptionType.unknown, DioExceptionType.cancel];

      for (final type in appErrorTypes) {
        expectDioTypeMapsToAppError(
          mapper: sut,
          requestOptions: requestOptions,
          stackTrace: stackTrace,
          type: type,
        );
      }
    },
  );

  test(
    'DioException with NO response data and type other than unknown/cancel type maps to network error',
    () {
      final networkErrorTypes = [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.badCertificate,
        DioExceptionType.badResponse,
        DioExceptionType.connectionError,
      ];

      for (final type in networkErrorTypes) {
        expectDioTypeMapsToNetworkError(
          mapper: sut,
          requestOptions: requestOptions,
          stackTrace: stackTrace,
          type: type,
        );
      }
    },
  );
}
