// ignore_for_file: lines_longer_than_80_chars, avoid_redundant_argument_values, cascade_invocations

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_kit/src/clients/dio_net_client.dart';
import 'package:net_kit/src/clients/net_client.dart';
import 'package:net_kit/src/enums/http_method.dart';
import 'package:net_kit/src/enums/parse_target_type.dart';
import 'package:net_kit/src/enums/transport_error_type.dart';
import 'package:net_kit/src/models/error_response_data.dart';
import 'package:net_kit/src/models/net_kit_exception.dart';
import 'package:net_kit/src/models/request_spec.dart';
import 'package:net_kit/src/models/response_context.dart';
import 'package:net_kit/src/models/result.dart';
import 'package:net_kit/src/services/cancellation/request_canceller.dart';
import 'package:net_kit/src/services/codec/request_data_codec.dart';
import 'package:net_kit/src/services/mappers/client_exception_mapper.dart';
import 'package:net_kit/src/services/mappers/response_classifier.dart';
import 'package:net_kit/src/services/transformers/error_response_data_transformer.dart';
import 'package:net_kit/src/services/transformers/request_data_transformer.dart';
import 'package:net_kit/src/services/transformers/successful_response_data_transformer.dart';
import 'package:test/test.dart';

class MockDio extends Mock implements Dio {}

class MockRequestDataTransformer extends Mock
    implements RequestDataTransformer {}

class MockErrorResponseDataTransformer extends Mock
    implements ErrorResponseDataTransformer {}

class MockSuccessfulResponseDataTransformer extends Mock
    implements SuccessfulResponseDataTransformer {}

class MockClientExceptionMapper extends Mock implements ClientExceptionMapper {}

class MockRequestCodec extends Mock
    implements RequestDataCodec<String, String, String> {}

class MockResponseClassifier extends Mock implements ResponseClassifier {}

class FakeRequestOptions extends Fake implements RequestOptions {}

class FakeResponseContext extends Fake implements ResponseContext {}

void main() {
  late MockDio mockDio;
  late MockRequestDataTransformer mockRequestDataTransformer;
  late MockErrorResponseDataTransformer mockErrorResponseDataTransformer;
  late MockSuccessfulResponseDataTransformer
      mockSuccessfulResponseDataTransformer;
  late MockClientExceptionMapper mockClientExceptionMapper;
  late MockRequestCodec mockRequestCodec;
  late MockResponseClassifier mockResponseClassifier;
  late RequestSpec<String> spec;

  late NetClient sut;

  setUpAll(() {
    registerFallbackValue(FakeRequestOptions());
    registerFallbackValue(FakeResponseContext());
  });

  setUp(() {
    mockDio = MockDio();
    mockRequestDataTransformer = MockRequestDataTransformer();
    mockErrorResponseDataTransformer = MockErrorResponseDataTransformer();
    mockSuccessfulResponseDataTransformer =
        MockSuccessfulResponseDataTransformer();
    mockClientExceptionMapper = MockClientExceptionMapper();
    mockRequestCodec = MockRequestCodec();
    mockResponseClassifier = MockResponseClassifier();

    spec = RequestSpec<String>(
      pathOrUrl: '/users',
      method: HttpMethod.POST,
      body: 'request-body',
      queryParameters: const {'page': 1},
      headers: const {'authorization': 'Bearer token'},
    );

    sut = DioNetClient.test(
      mockDio,
      mockRequestDataTransformer,
      mockErrorResponseDataTransformer,
      mockSuccessfulResponseDataTransformer,
      mockClientExceptionMapper,
    );
  });

  test(
    'Execute returns request data transformer error without calling client',
    () async {
      const parseException = ParseException(
        targetType: ParseTargetType.REQUEST_ENCODE,
        data: 'request-body',
      );

      when(
        () => mockRequestDataTransformer.transform<String>(
          'request-body',
          mockRequestCodec,
        ),
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
        () => mockDio.fetch<dynamic>(any()),
      );
    },
  );

  test(
    'Execute passes null cancelToken when requestCanceller is null',
    () async {
      const encodedBody = {'name': 'Alice'};
      const responseData = {'id': 1};
      const decodedResponse = 'decoded-response';
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: spec.pathOrUrl),
        statusCode: 200,
        data: responseData,
      );

      when(
        () => mockRequestDataTransformer.transform<String>(
          'request-body',
          mockRequestCodec,
        ),
      ).thenReturn(Result.success(encodedBody));
      when(
        () => mockDio.fetch<dynamic>(any()),
      ).thenAnswer((_) async => response);
      when(() => mockResponseClassifier.isError(any())).thenReturn(false);
      when(
        () => mockSuccessfulResponseDataTransformer.transform<String>(
          responseData,
          mockRequestCodec,
        ),
      ).thenReturn(Result.success(decodedResponse));

      final result = await sut.execute(
        spec: spec,
        codec: mockRequestCodec,
        responseClassifier: mockResponseClassifier,
      );

      expect(result.isSuccess, isTrue);
      expect(result.resultOrNull?.data.resultOrNull, decodedResponse);
      final capturedRequest = verify(
        () => mockDio.fetch<dynamic>(captureAny()),
      ).captured.single as RequestOptions;
      expect(capturedRequest.path, spec.pathOrUrl);
      expect(capturedRequest.data, encodedBody);
      expect(capturedRequest.queryParameters, spec.queryParameters);
      expect(capturedRequest.cancelToken, isNull);
      expect(capturedRequest.onSendProgress, isNull);
      expect(capturedRequest.onReceiveProgress, isNull);
    },
  );

  test(
    'Execute passes an already-cancelled cancelToken when requestCanceller is already cancelled',
    () async {
      const encodedBody = {'name': 'Alice'};
      const responseData = {'id': 1};
      const decodedResponse = 'decoded-response';
      final requestCanceller = RequestCanceller<String>();
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: spec.pathOrUrl),
        statusCode: 200,
        data: responseData,
      );

      requestCanceller.cancel(reason: 'user aborted');

      when(
        () => mockRequestDataTransformer.transform<String>(
          'request-body',
          mockRequestCodec,
        ),
      ).thenReturn(Result.success(encodedBody));
      when(
        () => mockDio.fetch<dynamic>(any()),
      ).thenAnswer((invocation) async {
        final requestOptions =
            invocation.positionalArguments.single as RequestOptions;
        final cancelToken = requestOptions.cancelToken;

        expect(cancelToken, isNotNull);
        expect(cancelToken!.isCancelled, isTrue);
        expect(requestOptions.path, spec.pathOrUrl);
        expect(requestOptions.data, encodedBody);
        expect(requestOptions.queryParameters, spec.queryParameters);
        expect(requestCanceller.requestSpec, same(spec));

        return response;
      });
      when(() => mockResponseClassifier.isError(any())).thenReturn(false);
      when(
        () => mockSuccessfulResponseDataTransformer.transform<String>(
          responseData,
          mockRequestCodec,
        ),
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
    'Execute cancels the Dio cancelToken when requestCanceller is cancelled later',
    () async {
      const encodedBody = {'name': 'Alice'};
      const responseData = {'id': 1};
      const decodedResponse = 'decoded-response';
      final requestCanceller = RequestCanceller<String>();
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: spec.pathOrUrl),
        statusCode: 200,
        data: responseData,
      );
      final requestStarted = Completer<void>();
      final cancellationObserved = Completer<void>();

      when(
        () => mockRequestDataTransformer.transform<String>(
          'request-body',
          mockRequestCodec,
        ),
      ).thenReturn(Result.success(encodedBody));
      when(
        () => mockDio.fetch<dynamic>(any()),
      ).thenAnswer((invocation) async {
        final requestOptions =
            invocation.positionalArguments.single as RequestOptions;
        final cancelToken = requestOptions.cancelToken;

        expect(cancelToken, isNotNull);
        expect(cancelToken!.isCancelled, isFalse);
        expect(requestOptions.path, spec.pathOrUrl);
        expect(requestOptions.data, encodedBody);
        expect(requestOptions.queryParameters, spec.queryParameters);
        expect(requestCanceller.requestSpec, same(spec));

        requestStarted.complete();
        await requestCanceller.whenCancel;

        expect(cancelToken.isCancelled, isTrue);
        cancellationObserved.complete();

        return response;
      });
      when(() => mockResponseClassifier.isError(any())).thenReturn(false);
      when(
        () => mockSuccessfulResponseDataTransformer.transform<String>(
          responseData,
          mockRequestCodec,
        ),
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
    'Execute returns ParseException for undecodable classified error body',
    () async {
      const encodedBody = {'name': 'Alice'};
      const responseData = {'code': 'invalid'};
      const parseException = ParseException(
        targetType: ParseTargetType.ERROR_DECODE,
        data: responseData,
      );
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: spec.pathOrUrl),
        statusCode: 422,
        data: responseData,
      );

      when(
        () => mockRequestDataTransformer.transform<String>(
          'request-body',
          mockRequestCodec,
        ),
      ).thenReturn(Result.success(encodedBody));
      when(
        () => mockDio.fetch<dynamic>(any()),
      ).thenAnswer((_) async => response);
      when(() => mockResponseClassifier.isError(any())).thenReturn(true);
      when(
        () => mockErrorResponseDataTransformer.transform<String>(
          responseData,
          mockRequestCodec,
        ),
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
    'Execute returns decoded error response data for classified error response',
    () async {
      const encodedBody = {'name': 'Alice'};
      const responseData = {'code': 'invalid'};
      const decodedError = 'decoded-error';
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: spec.pathOrUrl),
        statusCode: 422,
        data: responseData,
        headers: Headers.fromMap(const {
          'x-trace-id': ['trace-1'],
        }),
      );

      when(
        () => mockRequestDataTransformer.transform<String>(
          'request-body',
          mockRequestCodec,
        ),
      ).thenReturn(Result.success(encodedBody));
      when(
        () => mockDio.fetch<dynamic>(any()),
      ).thenAnswer((_) async => response);
      when(() => mockResponseClassifier.isError(any())).thenReturn(true);
      when(
        () => mockErrorResponseDataTransformer.transform<String>(
          responseData,
          mockRequestCodec,
        ),
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
    'Execute returns ParseException for undecodable success body',
    () async {
      const encodedBody = {'name': 'Alice'};
      const responseData = {'id': 1};
      const parseException = ParseException(
        targetType: ParseTargetType.RESPONSE_DECODE,
        data: responseData,
      );
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: spec.pathOrUrl),
        statusCode: 200,
        data: responseData,
      );

      when(
        () => mockRequestDataTransformer.transform<String>(
          'request-body',
          mockRequestCodec,
        ),
      ).thenReturn(Result.success(encodedBody));
      when(
        () => mockDio.fetch<dynamic>(any()),
      ).thenAnswer((_) async => response);
      when(() => mockResponseClassifier.isError(any())).thenReturn(false);
      when(
        () => mockSuccessfulResponseDataTransformer.transform<String>(
          responseData,
          mockRequestCodec,
        ),
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
    'Execute returns decoded success payload for non-error response',
    () async {
      const encodedBody = {'name': 'Alice'};
      const responseData = {'id': 1};
      const decodedResponse = 'decoded-response';
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: spec.pathOrUrl),
        statusCode: 200,
        data: responseData,
        headers: Headers.fromMap(const {
          'content-type': ['application/json'],
        }),
      );

      void onSendProgress(_, __) {}

      void onReceiveProgress(_, __) {}

      when(
        () => mockRequestDataTransformer.transform<String>(
          'request-body',
          mockRequestCodec,
        ),
      ).thenReturn(Result.success(encodedBody));
      when(
        () => mockDio.fetch<dynamic>(any()),
      ).thenAnswer((_) async => response);
      when(() => mockResponseClassifier.isError(any())).thenReturn(false);
      when(
        () => mockSuccessfulResponseDataTransformer.transform<String>(
          responseData,
          mockRequestCodec,
        ),
      ).thenReturn(Result.success(decodedResponse));

      final result = await sut.execute(
        spec: spec,
        codec: mockRequestCodec,
        responseClassifier: mockResponseClassifier,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      final capturedRequest = verify(
        () => mockDio.fetch<dynamic>(captureAny()),
      ).captured.single as RequestOptions;

      expect(result.isSuccess, isTrue);
      expect(result.errorOrNull, isNull);
      expect(result.resultOrNull?.statusCode, 200);
      expect(result.resultOrNull?.headers, response.headers.map);
      expect(result.resultOrNull?.requestSpec, same(spec));
      expect(result.resultOrNull?.data.isSuccess, isTrue);
      expect(result.resultOrNull?.data.resultOrNull, decodedResponse);
      expect(capturedRequest.path, spec.pathOrUrl);
      expect(capturedRequest.data, encodedBody);
      expect(capturedRequest.queryParameters, spec.queryParameters);
      expect(capturedRequest.cancelToken, isNull);
      expect(capturedRequest.method, spec.method.value);
      expect(capturedRequest.headers, spec.headers);
      expect(capturedRequest.onSendProgress, same(onSendProgress));
      expect(capturedRequest.onReceiveProgress, same(onReceiveProgress));
      expect(capturedRequest.sendTimeout, isNull);
      expect(capturedRequest.receiveTimeout, isNull);
      expect(capturedRequest.connectTimeout, isNull);
    },
  );

  test(
    'Execute passes per-request send and receive timeouts via Dio options',
    () async {
      const encodedBody = {'name': 'Alice'};
      const responseData = {'id': 1};
      const decodedResponse = 'decoded-response';
      final timedSpec = RequestSpec<String>(
        pathOrUrl: 'https://api.example.com/users',
        method: HttpMethod.HEAD,
        body: 'request-body',
        sendTimeout: const Duration(seconds: 2),
        receiveTimeout: const Duration(seconds: 3),
      );
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: timedSpec.pathOrUrl),
        statusCode: 200,
        data: responseData,
      );

      when(
        () => mockRequestDataTransformer.transform<String>(
          'request-body',
          mockRequestCodec,
        ),
      ).thenReturn(Result.success(encodedBody));
      when(
        () => mockDio.fetch<dynamic>(any()),
      ).thenAnswer((_) async => response);
      when(() => mockResponseClassifier.isError(any())).thenReturn(false);
      when(
        () => mockSuccessfulResponseDataTransformer.transform<String>(
          responseData,
          mockRequestCodec,
        ),
      ).thenReturn(Result.success(decodedResponse));

      final result = await sut.execute(
        spec: timedSpec,
        codec: mockRequestCodec,
        responseClassifier: mockResponseClassifier,
      );

      final capturedRequest = verify(
        () => mockDio.fetch<dynamic>(captureAny()),
      ).captured.single as RequestOptions;

      expect(result.isSuccess, isTrue);
      expect(capturedRequest.path, timedSpec.pathOrUrl);
      expect(capturedRequest.data, encodedBody);
      expect(capturedRequest.queryParameters, timedSpec.queryParameters);
      expect(capturedRequest.cancelToken, isNull);
      expect(capturedRequest.method, HttpMethod.HEAD.value);
      expect(capturedRequest.sendTimeout, timedSpec.sendTimeout);
      expect(capturedRequest.receiveTimeout, timedSpec.receiveTimeout);
    },
  );

  test(
    'Execute returns outer error when client exception mapper fails',
    () async {
      final exception = DioException(
        requestOptions: RequestOptions(path: spec.pathOrUrl),
        type: DioExceptionType.connectionError,
      );
      const mappedException =
          TransportException(TransportErrorType.CONNECTION_ERROR);

      when(
        () => mockRequestDataTransformer.transform<String>(
          'request-body',
          mockRequestCodec,
        ),
      ).thenReturn(Result.success('encoded'));
      when(
        () => mockDio.fetch<dynamic>(any()),
      ).thenThrow(exception);
      when(
        () => mockClientExceptionMapper.mapException<String>(
          exception,
          stackTrace: any(named: 'stackTrace'),
          errorResponseDataDecoder: mockRequestCodec,
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
    'Execute returns decoded error response data when client exception mapper succeeds',
    () async {
      final exception = DioException(
        requestOptions: RequestOptions(path: spec.pathOrUrl),
        type: DioExceptionType.badResponse,
      );
      const errorResponseData = ErrorResponseData<String>(
        statusCode: 409,
        error: 'decoded-error',
        headers: {
          'retry-after': ['30']
        },
      );

      when(
        () => mockRequestDataTransformer.transform<String>(
          'request-body',
          mockRequestCodec,
        ),
      ).thenReturn(Result.success('encoded'));
      when(
        () => mockDio.fetch<dynamic>(any()),
      ).thenThrow(exception);
      when(
        () => mockClientExceptionMapper.mapException<String>(
          exception,
          stackTrace: any(named: 'stackTrace'),
          errorResponseDataDecoder: mockRequestCodec,
        ),
      ).thenReturn(Result.success(errorResponseData));

      final result = await sut.execute(
        spec: spec,
        codec: mockRequestCodec,
        responseClassifier: mockResponseClassifier,
      );

      expect(result.isSuccess, isTrue);
      expect(result.errorOrNull, isNull);
      expect(result.resultOrNull?.statusCode, 409);
      expect(result.resultOrNull?.headers, errorResponseData.headers);
      expect(result.resultOrNull?.requestSpec, same(spec));
      expect(result.resultOrNull?.data.isError, isTrue);
      expect(result.resultOrNull?.data.errorOrNull, errorResponseData.error);
    },
  );
}
