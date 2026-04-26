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
import 'package:net_kit/src/models/request_body.dart';
import 'package:net_kit/src/models/request_spec.dart';
import 'package:net_kit/src/models/response_context.dart';
import 'package:net_kit/src/models/result.dart';
import 'package:net_kit/src/services/cancellation/request_canceller.dart';
import 'package:net_kit/src/services/codec/response_data_codec.dart';
import 'package:net_kit/src/services/mappers/client_exception_mapper.dart';
import 'package:net_kit/src/services/mappers/response_classifier.dart';
import 'package:net_kit/src/services/resolver/request_body_content_type_resolver.dart';
import 'package:net_kit/src/services/transformers/request/request_body_transformer.dart';
import 'package:net_kit/src/services/transformers/response/error_response_data_transformer.dart';
import 'package:net_kit/src/services/transformers/response/successful_response_data_transformer.dart';
import 'package:test/test.dart';

class MockDio extends Mock implements Dio {}

class MockRequestBodyTransformer extends Mock
    implements RequestBodyTransformer {}

class MockErrorResponseDataTransformer extends Mock
    implements ErrorResponseDataTransformer {}

class MockSuccessfulResponseDataTransformer extends Mock
    implements SuccessfulResponseDataTransformer {}

class MockClientExceptionMapper extends Mock implements ClientExceptionMapper {}

class MockResponseCodec extends Mock
    implements ResponseDataCodec<String, String> {}

class MockResponseClassifier extends Mock implements ResponseClassifier {}

class FakeOptions extends Fake implements Options {}

class FakeResponseContext extends Fake implements ResponseContext {}

void main() {
  late MockDio mockDio;
  late MockRequestBodyTransformer mockRequestBodyTransformer;
  late MockErrorResponseDataTransformer mockErrorResponseDataTransformer;
  late MockSuccessfulResponseDataTransformer
      mockSuccessfulResponseDataTransformer;
  late MockClientExceptionMapper mockClientExceptionMapper;
  late MockResponseCodec mockRequestCodec;
  late MockResponseClassifier mockResponseClassifier;
  late RequestSpec spec;

  late NetClient sut;

  setUpAll(() {
    registerFallbackValue(FakeOptions());
    registerFallbackValue(FakeResponseContext());
  });

  setUp(() {
    mockDio = MockDio();
    mockRequestBodyTransformer = MockRequestBodyTransformer();
    mockErrorResponseDataTransformer = MockErrorResponseDataTransformer();
    mockSuccessfulResponseDataTransformer =
        MockSuccessfulResponseDataTransformer();
    mockClientExceptionMapper = MockClientExceptionMapper();
    mockRequestCodec = MockResponseCodec();
    mockResponseClassifier = MockResponseClassifier();

    spec = RequestSpec(
      pathOrUrl: '/users',
      method: HttpMethod.POST,
      body: const JsonBody({'name': 'Alice'}),
      queryParameters: const {'page': 1},
      headers: const {'authorization': 'Bearer token'},
      followRedirects: false,
      maxRedirects: 1,
    );

    sut = DioNetClient.test(
      mockDio,
      mockRequestBodyTransformer,
      const DefaultRequestBodyContentTypeResolver(),
      mockErrorResponseDataTransformer,
      mockSuccessfulResponseDataTransformer,
      mockClientExceptionMapper,
    );
  });

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

      when(() => mockRequestBodyTransformer.transform(spec.body))
          .thenReturn(encodedBody);
      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
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
      final verification = verify(
        () => mockDio.request<dynamic>(
          captureAny(),
          data: captureAny(named: 'data'),
          queryParameters: captureAny(named: 'queryParameters'),
          options: captureAny(named: 'options'),
          cancelToken: captureAny(named: 'cancelToken'),
          onSendProgress: captureAny(named: 'onSendProgress'),
          onReceiveProgress: captureAny(named: 'onReceiveProgress'),
        ),
      );
      final captured = verification.captured;
      final capturedOptions = captured[3] as Options;
      expect(captured[0], spec.pathOrUrl);
      expect(captured[1], encodedBody);
      expect(captured[2], spec.queryParameters);
      expect(capturedOptions.contentType, Headers.jsonContentType);
      expect(captured[4], isNull);
      expect(captured[5], isNull);
      expect(captured[6], isNull);
    },
  );

  test(
    'Execute sends null request data and no inferred content type for null body',
    () async {
      const responseData = {'id': 1};
      const decodedResponse = 'decoded-response';
      final bodylessSpec = RequestSpec(
        pathOrUrl: '/health',
        method: HttpMethod.GET,
      );
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: bodylessSpec.pathOrUrl),
        statusCode: 200,
        data: responseData,
      );

      when(() => mockRequestBodyTransformer.transform(bodylessSpec.body))
          .thenReturn(null);
      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      ).thenAnswer((_) async => response);
      when(() => mockResponseClassifier.isError(any())).thenReturn(false);
      when(
        () => mockSuccessfulResponseDataTransformer.transform<String>(
          responseData,
          mockRequestCodec,
        ),
      ).thenReturn(Result.success(decodedResponse));

      final result = await sut.execute(
        spec: bodylessSpec,
        codec: mockRequestCodec,
        responseClassifier: mockResponseClassifier,
      );

      final verification = verify(
        () => mockDio.request<dynamic>(
          captureAny(),
          data: captureAny(named: 'data'),
          queryParameters: captureAny(named: 'queryParameters'),
          options: captureAny(named: 'options'),
          cancelToken: captureAny(named: 'cancelToken'),
          onSendProgress: captureAny(named: 'onSendProgress'),
          onReceiveProgress: captureAny(named: 'onReceiveProgress'),
        ),
      );
      final captured = verification.captured;
      final capturedOptions = captured[3] as Options;

      expect(result.isSuccess, isTrue);
      expect(captured[0], bodylessSpec.pathOrUrl);
      expect(captured[1], isNull);
      expect(capturedOptions.contentType, isNull);
    },
  );

  test(
    'Execute passes an already-cancelled cancelToken when requestCanceller is already cancelled',
    () async {
      const encodedBody = {'name': 'Alice'};
      const responseData = {'id': 1};
      const decodedResponse = 'decoded-response';
      final requestCanceller = RequestCanceller();
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: spec.pathOrUrl),
        statusCode: 200,
        data: responseData,
      );

      requestCanceller.cancel(reason: 'user aborted');

      when(() => mockRequestBodyTransformer.transform(spec.body))
          .thenReturn(encodedBody);
      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      ).thenAnswer((invocation) async {
        final path = invocation.positionalArguments.single as String;
        final data = invocation.namedArguments[#data];
        final queryParameters = invocation.namedArguments[#queryParameters];
        final cancelToken =
            invocation.namedArguments[#cancelToken] as CancelToken?;

        expect(cancelToken, isNotNull);
        expect(cancelToken!.isCancelled, isTrue);
        expect(path, spec.pathOrUrl);
        expect(data, encodedBody);
        expect(queryParameters, spec.queryParameters);
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
      final requestCanceller = RequestCanceller();
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: spec.pathOrUrl),
        statusCode: 200,
        data: responseData,
      );
      final requestStarted = Completer<void>();
      final cancellationObserved = Completer<void>();

      when(() => mockRequestBodyTransformer.transform(spec.body))
          .thenReturn(encodedBody);
      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      ).thenAnswer((invocation) async {
        final path = invocation.positionalArguments.single as String;
        final data = invocation.namedArguments[#data];
        final queryParameters = invocation.namedArguments[#queryParameters];
        final cancelToken =
            invocation.namedArguments[#cancelToken] as CancelToken?;

        expect(cancelToken, isNotNull);
        expect(cancelToken!.isCancelled, isFalse);
        expect(path, spec.pathOrUrl);
        expect(data, encodedBody);
        expect(queryParameters, spec.queryParameters);
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

      when(() => mockRequestBodyTransformer.transform(spec.body))
          .thenReturn(encodedBody);
      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
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

      when(() => mockRequestBodyTransformer.transform(spec.body))
          .thenReturn(encodedBody);
      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
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

      when(() => mockRequestBodyTransformer.transform(spec.body))
          .thenReturn(encodedBody);
      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
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
    'Execute passes request values to Dio request/options',
    () async {
      const encodedBody = {'name': 'Alice'};
      const responseData = {'id': 1};
      const decodedResponse = 'decoded-response';

      void onSendProgress(_, __) {}

      void onReceiveProgress(_, __) {}

      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: spec.pathOrUrl),
        statusCode: 200,
        data: responseData,
      );

      when(() => mockRequestBodyTransformer.transform(spec.body))
          .thenReturn(encodedBody);
      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
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

      final verification = verify(
        () => mockDio.request<dynamic>(
          captureAny(),
          data: captureAny(named: 'data'),
          queryParameters: captureAny(named: 'queryParameters'),
          options: captureAny(named: 'options'),
          cancelToken: captureAny(named: 'cancelToken'),
          onSendProgress: captureAny(named: 'onSendProgress'),
          onReceiveProgress: captureAny(named: 'onReceiveProgress'),
        ),
      );
      final captured = verification.captured;
      final capturedOptions = captured[3] as Options;

      expect(result.isSuccess, isTrue);
      expect(captured[0], spec.pathOrUrl);
      expect(captured[1], encodedBody);
      expect(captured[2], spec.queryParameters);
      expect(captured[4], isNull);
      expect(capturedOptions.method, spec.method.value);
      expect(capturedOptions.headers, spec.headers);
      expect(capturedOptions.contentType, Headers.jsonContentType);
      expect(capturedOptions.followRedirects, spec.followRedirects);
      expect(capturedOptions.maxRedirects, spec.maxRedirects);
      expect(captured[5], same(onSendProgress));
      expect(captured[6], same(onReceiveProgress));
      expect(capturedOptions.sendTimeout, isNull);
      expect(capturedOptions.receiveTimeout, isNull);
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

      when(() => mockRequestBodyTransformer.transform(spec.body))
          .thenReturn(encodedBody);
      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
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
      expect(result.errorOrNull, isNull);
      expect(result.resultOrNull?.statusCode, 200);
      expect(result.resultOrNull?.headers, response.headers.map);
      expect(result.resultOrNull?.requestSpec, same(spec));
      expect(result.resultOrNull?.data.isSuccess, isTrue);
      expect(result.resultOrNull?.data.resultOrNull, decodedResponse);
    },
  );

  test(
    'Execute passes per-request send and receive timeouts via Dio options',
    () async {
      const encodedBody = {'name': 'Alice'};
      const responseData = {'id': 1};
      const decodedResponse = 'decoded-response';
      final timedSpec = RequestSpec(
        pathOrUrl: 'https://api.example.com/users',
        method: HttpMethod.HEAD,
        body: const JsonBody({'name': 'Alice'}),
        sendTimeout: const Duration(seconds: 2),
        receiveTimeout: const Duration(seconds: 3),
      );
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: timedSpec.pathOrUrl),
        statusCode: 200,
        data: responseData,
      );

      when(() => mockRequestBodyTransformer.transform(timedSpec.body))
          .thenReturn(encodedBody);
      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
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

      final verification = verify(
        () => mockDio.request<dynamic>(
          captureAny(),
          data: captureAny(named: 'data'),
          queryParameters: captureAny(named: 'queryParameters'),
          options: captureAny(named: 'options'),
          cancelToken: captureAny(named: 'cancelToken'),
          onSendProgress: captureAny(named: 'onSendProgress'),
          onReceiveProgress: captureAny(named: 'onReceiveProgress'),
        ),
      );
      final captured = verification.captured;
      final capturedOptions = captured[3] as Options;

      expect(result.isSuccess, isTrue);
      expect(captured[0], timedSpec.pathOrUrl);
      expect(captured[1], encodedBody);
      expect(captured[2], timedSpec.queryParameters);
      expect(captured[4], isNull);
      expect(capturedOptions.method, HttpMethod.HEAD.value);
      expect(capturedOptions.contentType, Headers.jsonContentType);
      expect(capturedOptions.sendTimeout, timedSpec.sendTimeout);
      expect(capturedOptions.receiveTimeout, timedSpec.receiveTimeout);
      expect(capturedOptions.followRedirects, isNull);
      expect(capturedOptions.maxRedirects, isNull);
    },
  );

  test(
    'Execute uses explicit RequestSpec contentType over inferred content type',
    () async {
      const explicitContentType = 'application/vnd.custom+json';
      const encodedBody = {'name': 'Alice'};
      const responseData = {'id': 1};
      const decodedResponse = 'decoded-response';
      final overriddenSpec = RequestSpec(
        pathOrUrl: '/users',
        method: HttpMethod.POST,
        body: const JsonBody({'name': 'Alice'}),
        contentType: explicitContentType,
      );
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: overriddenSpec.pathOrUrl),
        statusCode: 200,
        data: responseData,
      );

      when(() => mockRequestBodyTransformer.transform(overriddenSpec.body))
          .thenReturn(encodedBody);
      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      ).thenAnswer((_) async => response);
      when(() => mockResponseClassifier.isError(any())).thenReturn(false);
      when(
        () => mockSuccessfulResponseDataTransformer.transform<String>(
          responseData,
          mockRequestCodec,
        ),
      ).thenReturn(Result.success(decodedResponse));

      final result = await sut.execute(
        spec: overriddenSpec,
        codec: mockRequestCodec,
        responseClassifier: mockResponseClassifier,
      );

      final verification = verify(
        () => mockDio.request<dynamic>(
          captureAny(),
          data: captureAny(named: 'data'),
          queryParameters: captureAny(named: 'queryParameters'),
          options: captureAny(named: 'options'),
          cancelToken: captureAny(named: 'cancelToken'),
          onSendProgress: captureAny(named: 'onSendProgress'),
          onReceiveProgress: captureAny(named: 'onReceiveProgress'),
        ),
      );
      final capturedOptions = verification.captured[3] as Options;

      expect(result.isSuccess, isTrue);
      expect(capturedOptions.contentType, explicitContentType);
    },
  );

  test(
    'Execute uses deduced content type when RequestSpec contentType is not set',
    () async {
      const encodedBody = {'name': 'Alice'};
      const responseData = {'id': 1};
      const decodedResponse = 'decoded-response';
      final inferredSpec = RequestSpec(
        pathOrUrl: '/users',
        method: HttpMethod.POST,
        body: const JsonBody({'name': 'Alice'}),
      );
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: inferredSpec.pathOrUrl),
        statusCode: 200,
        data: responseData,
      );

      when(() => mockRequestBodyTransformer.transform(inferredSpec.body))
          .thenReturn(encodedBody);
      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      ).thenAnswer((_) async => response);
      when(() => mockResponseClassifier.isError(any())).thenReturn(false);
      when(
        () => mockSuccessfulResponseDataTransformer.transform<String>(
          responseData,
          mockRequestCodec,
        ),
      ).thenReturn(Result.success(decodedResponse));

      final result = await sut.execute(
        spec: inferredSpec,
        codec: mockRequestCodec,
        responseClassifier: mockResponseClassifier,
      );

      final verification = verify(
        () => mockDio.request<dynamic>(
          captureAny(),
          data: captureAny(named: 'data'),
          queryParameters: captureAny(named: 'queryParameters'),
          options: captureAny(named: 'options'),
          cancelToken: captureAny(named: 'cancelToken'),
          onSendProgress: captureAny(named: 'onSendProgress'),
          onReceiveProgress: captureAny(named: 'onReceiveProgress'),
        ),
      );
      final captured = verification.captured;
      final capturedOptions = captured[3] as Options;

      expect(result.isSuccess, isTrue);
      expect(captured[0], inferredSpec.pathOrUrl);
      expect(captured[1], encodedBody);
      expect(capturedOptions.contentType, Headers.jsonContentType);
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

      when(() => mockRequestBodyTransformer.transform(spec.body))
          .thenReturn('encoded');
      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
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

      when(() => mockRequestBodyTransformer.transform(spec.body))
          .thenReturn('encoded');
      when(
        () => mockDio.request<dynamic>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
          cancelToken: any(named: 'cancelToken'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
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
