// ignore_for_file: lines_longer_than_80_chars, avoid_redundant_argument_values

import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_kit/src/enums/network_exception_type.dart';
import 'package:net_kit/src/enums/parse_target_type.dart';
import 'package:net_kit/src/models/error_response_data.dart';
import 'package:net_kit/src/models/net_client_exception.dart';
import 'package:net_kit/src/models/result.dart';
import 'package:net_kit/src/services/codec/net_client_response_decoder.dart';
import 'package:net_kit/src/services/mappers/client_exception_mapper.dart';
import 'package:net_kit/src/services/mappers/dio_client_exception_mapper.dart';
import 'package:test/test.dart';

class MockRequestOptions extends Mock implements RequestOptions {}

class MockNetClientResponseDecoder extends Mock
    implements NetClientResponseDecoder {}

void main() {
  const defaultResponseCode = 0;

  late MockRequestOptions mockRequestOptions;
  late MockNetClientResponseDecoder mockNetClientResponseDecoder;

  late ClientExceptionMapper sut;

  void verifyNetworkException(
    DioException exception,
    Object? expectedInnerCause,
    StackTrace? expectedStackTrace,
    NetworkExceptionType expectedType,
  ) {
    final result = sut.mapException(
      exception,
      stackTrace: expectedStackTrace,
      errorDecoder: (data) => data,
    );

    expect(
      result.errorOrNull,
      isA<NetworkException>()
          .having((p) => p.type, 'type', expectedType)
          .having((p) => p.cause, 'cause', expectedInnerCause)
          .having((p) => p.stackTrace, 'stackTrace', expectedStackTrace),
    );
    expect(result.isError, isTrue);
    expect(result.isSuccess, isFalse);
    expect(result.resultOrNull, isNull);
  }

  setUp(() {
    mockRequestOptions = MockRequestOptions();
    mockNetClientResponseDecoder = MockNetClientResponseDecoder();

    sut = DioClientExceptionMapper(
      defaultResponseCode,
      mockNetClientResponseDecoder,
    );

    when(() => mockRequestOptions.preserveHeaderCase).thenReturn(true);
  });

  test('If exception is not a DioException, returns UnexpectedException', () {
    final st = StackTrace.current;
    final cause = Exception('invalid-exception');
    final result = sut.mapException(
      cause,
      stackTrace: st,
      errorDecoder: (data) => data,
    );

    expect(
      result.errorOrNull,
      isA<UnexpectedException>()
          .having((p) => p.message, 'message', 'Received unknown exception')
          .having((p) => p.cause, 'cause', cause)
          .having((p) => p.stackTrace, 'stackTrace', st),
    );
    expect(result.isError, isTrue);
    expect(result.isSuccess, isFalse);
    expect(result.resultOrNull, isNull);
  });

  test(
    'If exception is a DioException of types other than badResponse, unknown, or cancel, returns NetworkException',
    () {
      final st = StackTrace.current;
      final innerCause = Exception();
      final matchingDioToNetworkExceptionTypes = [
        (
          DioExceptionType.connectionTimeout,
          NetworkExceptionType.CONNECTION_TIMEOUT
        ),
        (DioExceptionType.sendTimeout, NetworkExceptionType.SEND_TIMEOUT),
        (DioExceptionType.receiveTimeout, NetworkExceptionType.RECEIVE_TIMEOUT),
        (DioExceptionType.badCertificate, NetworkExceptionType.BAD_CERTIFICATE),
        (
          DioExceptionType.connectionError,
          NetworkExceptionType.CONNECTION_ERROR
        ),
      ];
      for (final type in matchingDioToNetworkExceptionTypes) {
        final dioException = DioException(
          requestOptions: mockRequestOptions,
          type: type.$1,
          error: innerCause,
          stackTrace: st,
        );

        verifyNetworkException(
          dioException,
          innerCause,
          st,
          type.$2,
        );
      }
    },
  );

  test(
    'If exception is a DioException of type cancel, returns CancellationException',
    () {
      final st = StackTrace.current;
      final innerCause = Exception();
      final dioException = DioException(
        requestOptions: mockRequestOptions,
        type: DioExceptionType.cancel,
        error: innerCause,
        stackTrace: st,
      );

      final result = sut.mapException(
        dioException,
        stackTrace: st,
        errorDecoder: (data) => data,
      );

      expect(
        result.errorOrNull,
        isA<CancellationException>()
            .having((p) => p.cause, 'cause', innerCause)
            .having((p) => p.stackTrace, 'stackTrace', st),
      );
      expect(result.isError, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.resultOrNull, isNull);
    },
  );

  test(
    'If exception is a DioException of type unknown, returns UnexpectedException',
    () {
      const msg = 'exp-msg';
      final st = StackTrace.current;
      final innerCause = Exception();
      final dioException = DioException(
        requestOptions: mockRequestOptions,
        type: DioExceptionType.unknown,
        error: innerCause,
        stackTrace: st,
        message: msg,
      );

      final result = sut.mapException(
        dioException,
        stackTrace: st,
        errorDecoder: (data) => data,
      );

      expect(
        result.errorOrNull,
        isA<UnexpectedException>()
            .having(
              (p) => p.message,
              'message',
              'Client threw unknown exception (${DioExceptionType.unknown.name}): $msg',
            )
            .having((p) => p.cause, 'cause', innerCause)
            .having((p) => p.stackTrace, 'stackTrace', st),
      );
      expect(result.isError, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.resultOrNull, isNull);
    },
  );

  test(
    'For DioException, exception stackTrace takes precedence over method stackTrace',
    () {
      final exceptionStackTrace = StackTrace.current;
      final methodStackTrace = StackTrace.fromString('method-stack-trace');
      final dioException = DioException(
        requestOptions: mockRequestOptions,
        type: DioExceptionType.cancel,
        stackTrace: exceptionStackTrace,
      );

      final result = sut.mapException(
        dioException,
        stackTrace: methodStackTrace,
        errorDecoder: (data) => data,
      );

      expect(
        result.errorOrNull,
        isA<CancellationException>().having(
          (p) => p.stackTrace,
          'stackTrace',
          same(exceptionStackTrace),
        ),
      );
      expect(result.isError, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.resultOrNull, isNull);
    },
  );

  test(
    'Type badResponse with null response returns UnexpectedException',
    () {
      final st = StackTrace.current;
      final innerCause = Exception();
      final dioException = DioException(
        requestOptions: mockRequestOptions,
        response: null,
        type: DioExceptionType.badResponse,
        error: innerCause,
        stackTrace: st,
      );

      final result = sut.mapException(
        dioException,
        stackTrace: st,
        errorDecoder: (data) => data,
      );

      expect(
        result.errorOrNull,
        isA<UnexpectedException>().having(
          (p) => p.message,
          'message',
          'Expected a response to be non-null',
        ),
      );
      expect(result.isError, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.resultOrNull, isNull);
    },
  );

  test(
    'Type badResponse with undecodable error returns decoder ParseException',
    () {
      const data = 'iamadata';
      const parseException = ParseException(
        targetType: ParseTargetType.ERROR_DECODE,
        data: data,
      );
      final dioException = DioException(
        requestOptions: mockRequestOptions,
        response: Response(requestOptions: mockRequestOptions, data: data),
        type: DioExceptionType.badResponse,
      );

      when(
        () => mockNetClientResponseDecoder.decode<Never>(any<dynamic>(), any()),
      ).thenReturn(Result.error(parseException));

      final result = sut.mapException(
        dioException,
        errorDecoder: (data) => throw Exception(),
      );

      expect(result.errorOrNull, same(parseException));
      expect(result.isError, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.resultOrNull, isNull);
    },
  );

  test(
    'Type badResponse passes response data and decoder to error response decoder',
    () {
      const data = 'iamadata';
      const decodedError = 'decoded-error';
      String decoder(dynamic input) => decodedError;

      final dioException = DioException(
        requestOptions: mockRequestOptions,
        response: Response(requestOptions: mockRequestOptions, data: data),
        type: DioExceptionType.badResponse,
      );

      when(
        () => mockNetClientResponseDecoder.decode<String>(data, decoder),
      ).thenReturn(Result.success(decodedError));

      sut.mapException(
        dioException,
        errorDecoder: decoder,
      );

      verify(
        () => mockNetClientResponseDecoder.decode<String>(data, decoder),
      ).called(1);
    },
  );

  test(
    'Type badResponse with decodable error returns DecodedErrorResponse',
    () {
      const data = 'iamadata';
      const decodedError = 'decoded-error';
      final st = StackTrace.current;
      final innerCause = Exception();
      final dioException = DioException(
        requestOptions: mockRequestOptions,
        response: Response(
          requestOptions: mockRequestOptions,
          statusCode: 400,
          data: data,
        ),
        type: DioExceptionType.badResponse,
        error: innerCause,
        stackTrace: st,
      );

      when(
        () =>
            mockNetClientResponseDecoder.decode<String>(any<dynamic>(), any()),
      ).thenReturn(Result.success(decodedError));

      final result = sut.mapException(
        dioException,
        errorDecoder: (data) => decodedError,
      );

      expect(
        result.resultOrNull,
        isA<ErrorResponseData<String>>()
            .having((p) => p.statusCode, 'statusCode', 400)
            .having((p) => p.error, 'error', decodedError),
      );
      expect(result.isSuccess, isTrue);
      expect(result.isError, isFalse);
      expect(result.errorOrNull, isNull);
    },
  );

  test(
    'Type badResponse with null statusCode uses the configured default status code',
    () {
      const data = 'iamadata';
      const decodedError = 'decoded-error';
      final dioException = DioException(
        requestOptions: mockRequestOptions,
        response: Response(
          requestOptions: mockRequestOptions,
          data: data,
        ),
        type: DioExceptionType.badResponse,
      );

      when(
        () =>
            mockNetClientResponseDecoder.decode<String>(any<dynamic>(), any()),
      ).thenReturn(Result.success(decodedError));

      final result = sut.mapException(
        dioException,
        errorDecoder: (data) => decodedError,
      );

      expect(
        result.resultOrNull,
        isA<ErrorResponseData<String>>()
            .having((p) => p.statusCode, 'statusCode', defaultResponseCode)
            .having((p) => p.error, 'error', decodedError),
      );
      expect(result.isSuccess, isTrue);
      expect(result.isError, isFalse);
      expect(result.errorOrNull, isNull);
    },
  );
}
