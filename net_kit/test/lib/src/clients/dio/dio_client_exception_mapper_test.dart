// ignore_for_file: lines_longer_than_80_chars, avoid_redundant_argument_values

import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_kit/src/clients/dio/dio_client_exception_mapper.dart';
import 'package:net_kit/src/enums/parse_target_type.dart';
import 'package:net_kit/src/enums/transport_error_type.dart';
import 'package:net_kit/src/models/error_response_data.dart';
import 'package:net_kit/src/models/net_kit_exception.dart';
import 'package:net_kit/src/models/result.dart';
import 'package:net_kit/src/services/codec/response_data_codec.dart';
import 'package:net_kit/src/services/mappers/client_exception_mapper.dart';
import 'package:net_kit/src/services/transformers/response/error_response_data_transformer.dart';
import 'package:test/test.dart';

class _MockRequestOptions extends Mock implements RequestOptions {}

class _MockErrorResponseDataTransformer extends Mock
    implements ErrorResponseDataTransformer {}

class TestErrorResponseDataDecoder implements ErrorResponseDataDecoder<String> {
  const TestErrorResponseDataDecoder(this.value);

  final String value;

  @override
  String decodeErrorData(dynamic raw) => value;
}

class ThrowingErrorResponseDataDecoder
    implements ErrorResponseDataDecoder<String> {
  const ThrowingErrorResponseDataDecoder(this.throwable);

  final Object throwable;

  @override
  // ignore: only_throw_errors
  String decodeErrorData(dynamic raw) => throw throwable;
}

void main() {
  const defaultResponseCode = 0;

  late _MockRequestOptions mockRequestOptions;
  late _MockErrorResponseDataTransformer mockErrorResponseDataTransformer;

  late ClientExceptionMapper sut;

  void verifyTransportException(
    DioException exception,
    Object? expectedInnerCause,
    StackTrace? expectedStackTrace,
    TransportErrorType expectedType,
  ) {
    final result = sut.mapException(
      exception,
      stackTrace: expectedStackTrace,
      errorResponseDataDecoder:
          const TestErrorResponseDataDecoder('decoded-error'),
    );

    expect(
      result.errorOrNull,
      isA<TransportException>()
          .having((p) => p.type, 'type', expectedType)
          .having((p) => p.cause, 'cause', expectedInnerCause)
          .having((p) => p.stackTrace, 'stackTrace', expectedStackTrace),
    );
    expect(result.isError, isTrue);
    expect(result.isSuccess, isFalse);
    expect(result.resultOrNull, isNull);
  }

  setUp(() {
    mockRequestOptions = _MockRequestOptions();
    mockErrorResponseDataTransformer = _MockErrorResponseDataTransformer();

    sut = DioClientExceptionMapper(
      defaultResponseCode,
      mockErrorResponseDataTransformer,
    );

    when(() => mockRequestOptions.preserveHeaderCase).thenReturn(true);
  });

  test('If exception is not a DioException, returns UnexpectedException', () {
    final st = StackTrace.current;
    final cause = Exception('invalid-exception');
    final result = sut.mapException(
      cause,
      stackTrace: st,
      errorResponseDataDecoder:
          const TestErrorResponseDataDecoder('decoded-error'),
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
    'If exception is a DioException of types other than badResponse, unknown, or cancel, returns TransportException',
    () {
      final st = StackTrace.current;
      final innerCause = Exception();
      final matchingDioToNetworkExceptionTypes = [
        (
          DioExceptionType.connectionTimeout,
          TransportErrorType.CONNECTION_TIMEOUT
        ),
        (DioExceptionType.sendTimeout, TransportErrorType.SEND_TIMEOUT),
        (DioExceptionType.receiveTimeout, TransportErrorType.RECEIVE_TIMEOUT),
        (DioExceptionType.badCertificate, TransportErrorType.BAD_CERTIFICATE),
        (DioExceptionType.connectionError, TransportErrorType.CONNECTION_ERROR),
      ];
      for (final type in matchingDioToNetworkExceptionTypes) {
        final dioException = DioException(
          requestOptions: mockRequestOptions,
          type: type.$1,
          error: innerCause,
          stackTrace: st,
        );

        verifyTransportException(
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
        errorResponseDataDecoder:
            const TestErrorResponseDataDecoder('decoded-error'),
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
        errorResponseDataDecoder:
            const TestErrorResponseDataDecoder('decoded-error'),
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
        errorResponseDataDecoder:
            const TestErrorResponseDataDecoder('decoded-error'),
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
        errorResponseDataDecoder:
            const TestErrorResponseDataDecoder('decoded-error'),
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
      final decoder =
          ThrowingErrorResponseDataDecoder(Exception('decode failed'));
      final dioException = DioException(
        requestOptions: mockRequestOptions,
        response: Response(requestOptions: mockRequestOptions, data: data),
        type: DioExceptionType.badResponse,
      );

      when(
        () => mockErrorResponseDataTransformer.transform<String>(data, decoder),
      ).thenReturn(Result.error(parseException));

      final result = sut.mapException(
        dioException,
        errorResponseDataDecoder: decoder,
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
      const decoder = TestErrorResponseDataDecoder(decodedError);

      final dioException = DioException(
        requestOptions: mockRequestOptions,
        response: Response(requestOptions: mockRequestOptions, data: data),
        type: DioExceptionType.badResponse,
      );

      when(
        () => mockErrorResponseDataTransformer.transform<String>(data, decoder),
      ).thenReturn(Result.success(decodedError));

      sut.mapException(
        dioException,
        errorResponseDataDecoder: decoder,
      );

      verify(
        () => mockErrorResponseDataTransformer.transform<String>(data, decoder),
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
      const decoder = TestErrorResponseDataDecoder(decodedError);
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
        () => mockErrorResponseDataTransformer.transform<String>(data, decoder),
      ).thenReturn(Result.success(decodedError));

      final result = sut.mapException(
        dioException,
        errorResponseDataDecoder: decoder,
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
      const decoder = TestErrorResponseDataDecoder(decodedError);
      final dioException = DioException(
        requestOptions: mockRequestOptions,
        response: Response(
          requestOptions: mockRequestOptions,
          data: data,
        ),
        type: DioExceptionType.badResponse,
      );

      when(
        () => mockErrorResponseDataTransformer.transform<String>(data, decoder),
      ).thenReturn(Result.success(decodedError));

      final result = sut.mapException(
        dioException,
        errorResponseDataDecoder: decoder,
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
