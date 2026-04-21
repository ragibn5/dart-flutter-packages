// ignore_for_file: lines_longer_than_80_chars, avoid_redundant_argument_values, cascade_invocations

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_kit/src/clients/net_client.dart';
import 'package:net_kit/src/clients/net_client_impl.dart';
import 'package:net_kit/src/enums/http_method.dart';
import 'package:net_kit/src/enums/network_exception_type.dart';
import 'package:net_kit/src/enums/parse_target_type.dart';
import 'package:net_kit/src/models/domain_exception.dart';
import 'package:net_kit/src/models/net_kit_exception.dart';
import 'package:net_kit/src/models/request_spec.dart';
import 'package:net_kit/src/models/response_context.dart';
import 'package:net_kit/src/models/result.dart';
import 'package:net_kit/src/services/client_exception_mapper.dart';
import 'package:net_kit/src/services/codec/net_kit_request_encoder.dart';
import 'package:net_kit/src/services/codec/net_kit_response_decoder.dart';
import 'package:net_kit/src/services/request_canceller.dart';
import 'package:net_kit/src/services/request_codec.dart';
import 'package:net_kit/src/services/response_classifier.dart';
import 'package:test/test.dart';

class MockDio extends Mock implements Dio {}

class MockRequestEncoder extends Mock implements NetKitRequestEncoder {}

class MockResponseDecoder extends Mock implements NetKitResponseDecoder {}

class MockClientExceptionMapper extends Mock implements ClientExceptionMapper {}

class MockRequestCodec extends Mock
    implements RequestCodec<String, String, String> {}

class MockResponseClassifier extends Mock implements ResponseClassifier {}

class FakeRequestOptions extends Fake implements RequestOptions {}

class FakeOptions extends Fake implements Options {}

class FakeResponseContext extends Fake implements ResponseContext {}

void main() {
  late MockDio mockDio;
  late MockRequestEncoder mockRequestEncoder;
  late MockResponseDecoder mockErrorResponseDecoder;
  late MockResponseDecoder mockSuccessfulResponseDecoder;
  late MockClientExceptionMapper mockClientExceptionMapper;
  late MockRequestCodec mockRequestCodec;
  late MockResponseClassifier mockResponseClassifier;
  late RequestSpec<String> spec;

  late NetClient sut;

  setUpAll(() {
    registerFallbackValue(FakeOptions());
    registerFallbackValue(FakeRequestOptions());
    registerFallbackValue(FakeResponseContext());
  });

  setUp(() {
    mockDio = MockDio();
    mockRequestEncoder = MockRequestEncoder();
    mockErrorResponseDecoder = MockResponseDecoder();
    mockSuccessfulResponseDecoder = MockResponseDecoder();
    mockClientExceptionMapper = MockClientExceptionMapper();
    mockRequestCodec = MockRequestCodec();
    mockResponseClassifier = MockResponseClassifier();

    spec = RequestSpec<String>(
      path: '/users',
      method: HttpMethod.POST,
      body: 'request-body',
      queryParameters: const {'page': 1},
      headers: const {'authorization': 'Bearer token'},
    );

    sut = NetClientImpl.test(
      mockDio,
      mockRequestEncoder,
      mockErrorResponseDecoder,
      mockSuccessfulResponseDecoder,
      mockClientExceptionMapper,
    );
  });

  test(
    'execute returns request encoder error without calling client',
    () async {
      const parseException = ParseException(
        targetType: ParseTargetType.REQUEST_ENCODE,
        data: 'request-body',
      );

      when(
        () => mockRequestEncoder.encode<String>('request-body', any()),
      ).thenReturn(Result.error(parseException));

      final result = await sut.execute(
        spec: spec,
        codec: mockRequestCodec,
        responseClassifier: mockResponseClassifier,
      );

      expect(result.isError, isTrue);
      expect(result.errorOrNull, same(parseException));
      expect(result.resultOrNull, isNull);
      verifyNever(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          cancelToken: any(named: 'cancelToken'),
          options: any(named: 'options'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      );
    },
  );

  test(
    'execute passes null cancelToken when requestCanceller is null',
    () async {
      const encodedBody = {'name': 'Alice'};
      const responseData = {'id': 1};
      const decodedResponse = 'decoded-response';
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: spec.path),
        statusCode: 200,
        data: responseData,
      );

      when(
        () => mockRequestEncoder.encode<String>('request-body', any()),
      ).thenReturn(Result.success(encodedBody));
      when(
        () => mockDio.request<dynamic>(
          spec.path,
          data: encodedBody,
          queryParameters: spec.queryParameters,
          cancelToken: null,
          options: any(named: 'options'),
          onSendProgress: null,
          onReceiveProgress: null,
        ),
      ).thenAnswer((_) async => response);
      when(() => mockResponseClassifier.isError(any())).thenReturn(false);
      when(
        () => mockSuccessfulResponseDecoder.decode<String>(responseData, any()),
      ).thenReturn(Result.success(decodedResponse));

      final result = await sut.execute(
        spec: spec,
        codec: mockRequestCodec,
        responseClassifier: mockResponseClassifier,
      );

      expect(result.isSuccess, isTrue);
      expect(result.resultOrNull?.data.resultOrNull, decodedResponse);
      verify(
        () => mockDio.request<dynamic>(
          spec.path,
          data: encodedBody,
          queryParameters: spec.queryParameters,
          cancelToken: null,
          options: any(named: 'options'),
          onSendProgress: null,
          onReceiveProgress: null,
        ),
      ).called(1);
    },
  );

  test(
    'execute passes an already-cancelled cancelToken when requestCanceller is already cancelled',
    () async {
      const encodedBody = {'name': 'Alice'};
      const responseData = {'id': 1};
      const decodedResponse = 'decoded-response';
      final requestCanceller = RequestCanceller<String>();
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: spec.path),
        statusCode: 200,
        data: responseData,
      );

      requestCanceller.cancel(reason: 'user aborted');

      when(
        () => mockRequestEncoder.encode<String>('request-body', any()),
      ).thenReturn(Result.success(encodedBody));
      when(
        () => mockDio.request<dynamic>(
          spec.path,
          data: encodedBody,
          queryParameters: spec.queryParameters,
          cancelToken: any(named: 'cancelToken'),
          options: any(named: 'options'),
          onSendProgress: null,
          onReceiveProgress: null,
        ),
      ).thenAnswer((invocation) async {
        final cancelToken =
            invocation.namedArguments[#cancelToken] as CancelToken?;

        expect(cancelToken, isNotNull);
        expect(cancelToken!.isCancelled, isTrue);
        expect(requestCanceller.requestSpec, same(spec));

        return response;
      });
      when(() => mockResponseClassifier.isError(any())).thenReturn(false);
      when(
        () => mockSuccessfulResponseDecoder.decode<String>(responseData, any()),
      ).thenReturn(Result.success(decodedResponse));

      final result = await sut.execute(
        spec: spec,
        codec: mockRequestCodec,
        responseClassifier: mockResponseClassifier,
        requestCanceller: requestCanceller,
      );

      expect(result.isSuccess, isTrue);
      expect(result.resultOrNull?.data.resultOrNull, decodedResponse);
    },
  );

  test(
    'execute cancels the Dio cancelToken when requestCanceller is cancelled later',
    () async {
      const encodedBody = {'name': 'Alice'};
      const responseData = {'id': 1};
      const decodedResponse = 'decoded-response';
      final requestCanceller = RequestCanceller<String>();
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: spec.path),
        statusCode: 200,
        data: responseData,
      );
      final requestStarted = Completer<void>();
      final cancellationObserved = Completer<void>();

      when(
        () => mockRequestEncoder.encode<String>('request-body', any()),
      ).thenReturn(Result.success(encodedBody));
      when(
        () => mockDio.request<dynamic>(
          spec.path,
          data: encodedBody,
          queryParameters: spec.queryParameters,
          cancelToken: any(named: 'cancelToken'),
          options: any(named: 'options'),
          onSendProgress: null,
          onReceiveProgress: null,
        ),
      ).thenAnswer((invocation) async {
        final cancelToken =
            invocation.namedArguments[#cancelToken] as CancelToken?;

        expect(cancelToken, isNotNull);
        expect(cancelToken!.isCancelled, isFalse);
        expect(requestCanceller.requestSpec, same(spec));

        requestStarted.complete();
        await requestCanceller.whenCancel;

        expect(cancelToken.isCancelled, isTrue);
        cancellationObserved.complete();

        return response;
      });
      when(() => mockResponseClassifier.isError(any())).thenReturn(false);
      when(
        () => mockSuccessfulResponseDecoder.decode<String>(responseData, any()),
      ).thenReturn(Result.success(decodedResponse));

      final resultFuture = sut.execute(
        spec: spec,
        codec: mockRequestCodec,
        responseClassifier: mockResponseClassifier,
        requestCanceller: requestCanceller,
      );

      await requestStarted.future;
      requestCanceller.cancel(reason: 'user aborted');
      await cancellationObserved.future;

      final result = await resultFuture;
      expect(result.isSuccess, isTrue);
      expect(result.resultOrNull?.data.resultOrNull, decodedResponse);
    },
  );

  test(
    'execute returns ParseException for undecodable classified error body',
    () async {
      const encodedBody = {'name': 'Alice'};
      const responseData = {'code': 'invalid'};
      const parseException = ParseException(
        targetType: ParseTargetType.ERROR_DECODE,
        data: responseData,
      );
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: spec.path),
        statusCode: 422,
        data: responseData,
      );

      when(
        () => mockRequestEncoder.encode<String>('request-body', any()),
      ).thenReturn(Result.success(encodedBody));
      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          cancelToken: any(named: 'cancelToken'),
          options: any(named: 'options'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      ).thenAnswer((_) async => response);
      when(() => mockResponseClassifier.isError(any())).thenReturn(true);
      when(
        () => mockErrorResponseDecoder.decode<String>(responseData, any()),
      ).thenReturn(Result.error(parseException));

      final result = await sut.execute(
        spec: spec,
        codec: mockRequestCodec,
        responseClassifier: mockResponseClassifier,
      );

      expect(result.isError, isTrue);
      expect(result.errorOrNull, same(parseException));
      expect(result.resultOrNull, isNull);
    },
  );

  test(
    'execute returns decoded error payload for classified error response',
    () async {
      const encodedBody = {'name': 'Alice'};
      const responseData = {'code': 'invalid'};
      const decodedError = 'decoded-error';
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: spec.path),
        statusCode: 422,
        data: responseData,
        headers: Headers.fromMap(const {
          'x-trace-id': ['trace-1'],
        }),
      );

      when(
        () => mockRequestEncoder.encode<String>('request-body', any()),
      ).thenReturn(Result.success(encodedBody));
      when(
        () => mockDio.request<dynamic>(
          spec.path,
          data: encodedBody,
          queryParameters: spec.queryParameters,
          cancelToken: null,
          options: any(named: 'options'),
          onSendProgress: null,
          onReceiveProgress: null,
        ),
      ).thenAnswer((_) async => response);
      when(() => mockResponseClassifier.isError(any())).thenReturn(true);
      when(
        () => mockErrorResponseDecoder.decode<String>(responseData, any()),
      ).thenReturn(Result.success(decodedError));

      final result = await sut.execute(
        spec: spec,
        codec: mockRequestCodec,
        responseClassifier: mockResponseClassifier,
      );

      expect(result.isSuccess, isTrue);
      expect(result.errorOrNull, isNull);
      expect(result.resultOrNull?.statusCode, 422);
      expect(result.resultOrNull?.headers, response.headers.map);
      expect(result.resultOrNull?.requestSpec, same(spec));
      expect(result.resultOrNull?.data.isError, isTrue);
      expect(result.resultOrNull?.data.errorOrNull, decodedError);
    },
  );

  test(
    'execute returns ParseException for undecodable success body',
    () async {
      const encodedBody = {'name': 'Alice'};
      const responseData = {'id': 1};
      const parseException = ParseException(
        targetType: ParseTargetType.RESPONSE_DECODE,
        data: responseData,
      );
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: spec.path),
        statusCode: 200,
        data: responseData,
      );

      when(
        () => mockRequestEncoder.encode<String>('request-body', any()),
      ).thenReturn(Result.success(encodedBody));
      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          cancelToken: any(named: 'cancelToken'),
          options: any(named: 'options'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      ).thenAnswer((_) async => response);
      when(() => mockResponseClassifier.isError(any())).thenReturn(false);
      when(
        () => mockSuccessfulResponseDecoder.decode<String>(responseData, any()),
      ).thenReturn(Result.error(parseException));

      final result = await sut.execute(
        spec: spec,
        codec: mockRequestCodec,
        responseClassifier: mockResponseClassifier,
      );

      expect(result.isError, isTrue);
      expect(result.errorOrNull, same(parseException));
      expect(result.resultOrNull, isNull);
    },
  );

  test(
    'execute returns decoded success payload for non-error response',
    () async {
      const encodedBody = {'name': 'Alice'};
      const responseData = {'id': 1};
      const decodedResponse = 'decoded-response';
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: spec.path),
        statusCode: 200,
        data: responseData,
        headers: Headers.fromMap(const {
          'content-type': ['application/json'],
        }),
      );

      void onSendProgress(_, __) {}

      void onReceiveProgress(_, __) {}

      when(
        () => mockRequestEncoder.encode<String>('request-body', any()),
      ).thenReturn(Result.success(encodedBody));
      when(
        () => mockDio.request<dynamic>(
          spec.path,
          data: encodedBody,
          queryParameters: spec.queryParameters,
          cancelToken: null,
          options: any(named: 'options'),
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        ),
      ).thenAnswer((_) async => response);
      when(() => mockResponseClassifier.isError(any())).thenReturn(false);
      when(
        () => mockSuccessfulResponseDecoder.decode<String>(responseData, any()),
      ).thenReturn(Result.success(decodedResponse));

      final result = await sut.execute(
        spec: spec,
        codec: mockRequestCodec,
        responseClassifier: mockResponseClassifier,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      final capturedOptions = verify(
        () => mockDio.request<dynamic>(
          spec.path,
          data: encodedBody,
          queryParameters: spec.queryParameters,
          cancelToken: null,
          options: captureAny(named: 'options'),
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        ),
      ).captured.single as Options;

      expect(result.isSuccess, isTrue);
      expect(result.errorOrNull, isNull);
      expect(result.resultOrNull?.statusCode, 200);
      expect(result.resultOrNull?.headers, response.headers.map);
      expect(result.resultOrNull?.requestSpec, same(spec));
      expect(result.resultOrNull?.data.isSuccess, isTrue);
      expect(result.resultOrNull?.data.resultOrNull, decodedResponse);
      expect(capturedOptions.method, spec.method.value);
      expect(capturedOptions.headers, spec.headers);
    },
  );

  test(
    'execute returns outer error when client exception mapper fails',
    () async {
      final exception = DioException(
        requestOptions: RequestOptions(path: spec.path),
        type: DioExceptionType.connectionError,
      );
      const mappedException =
          NetworkException(NetworkExceptionType.CONNECTION_ERROR);

      when(
        () => mockRequestEncoder.encode<String>('request-body', any()),
      ).thenReturn(Result.success('encoded'));
      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          cancelToken: any(named: 'cancelToken'),
          options: any(named: 'options'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      ).thenThrow(exception);
      when(
        () => mockClientExceptionMapper.mapException<String>(
          exception,
          stackTrace: any(named: 'stackTrace'),
          errorDecoder: any(named: 'errorDecoder'),
        ),
      ).thenReturn(Result.error(mappedException));

      final result = await sut.execute(
        spec: spec,
        codec: mockRequestCodec,
        responseClassifier: mockResponseClassifier,
      );

      expect(result.isError, isTrue);
      expect(result.errorOrNull, same(mappedException));
      expect(result.resultOrNull, isNull);
    },
  );

  test(
    'execute returns decoded error payload when client exception mapper succeeds',
    () async {
      final exception = DioException(
        requestOptions: RequestOptions(path: spec.path),
        type: DioExceptionType.badResponse,
      );
      const mappedDomainException = DomainException<String>(
        statusCode: 409,
        error: 'decoded-error',
        headers: {
          'retry-after': ['30']
        },
      );

      when(
        () => mockRequestEncoder.encode<String>('request-body', any()),
      ).thenReturn(Result.success('encoded'));
      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          cancelToken: any(named: 'cancelToken'),
          options: any(named: 'options'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      ).thenThrow(exception);
      when(
        () => mockClientExceptionMapper.mapException<String>(
          exception,
          stackTrace: any(named: 'stackTrace'),
          errorDecoder: any(named: 'errorDecoder'),
        ),
      ).thenReturn(Result.success(mappedDomainException));

      final result = await sut.execute(
        spec: spec,
        codec: mockRequestCodec,
        responseClassifier: mockResponseClassifier,
      );

      expect(result.isSuccess, isTrue);
      expect(result.errorOrNull, isNull);
      expect(result.resultOrNull?.statusCode, 409);
      expect(result.resultOrNull?.headers, mappedDomainException.headers);
      expect(result.resultOrNull?.requestSpec, same(spec));
      expect(result.resultOrNull?.data.isError, isTrue);
      expect(
        result.resultOrNull?.data.errorOrNull,
        mappedDomainException.error,
      );
    },
  );
}
