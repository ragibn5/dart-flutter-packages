// ignore_for_file: lines_longer_than_80_chars, avoid_redundant_argument_values, cascade_invocations

import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_kit/src/clients/dio/dio_cancel_token_factory.dart';
import 'package:net_kit/src/clients/dio/dio_net_client.dart';
import 'package:net_kit/src/clients/dio/dio_request_options_builder.dart';
import 'package:net_kit/src/clients/net_client.dart';
import 'package:net_kit/src/enums/http_method.dart';
import 'package:net_kit/src/enums/parse_target_type.dart';
import 'package:net_kit/src/enums/transport_error_type.dart';
import 'package:net_kit/src/models/default_client_config.dart';
import 'package:net_kit/src/models/error_response_data.dart';
import 'package:net_kit/src/models/net_kit_exception.dart';
import 'package:net_kit/src/models/request_body.dart';
import 'package:net_kit/src/models/request_spec.dart';
import 'package:net_kit/src/models/response_context.dart';
import 'package:net_kit/src/models/result.dart';
import 'package:net_kit/src/services/cancellation/request_canceller.dart';
import 'package:net_kit/src/services/codec/response_data_codec.dart';
import 'package:net_kit/src/services/composer/request_composer.dart';
import 'package:net_kit/src/services/mappers/client_exception_mapper.dart';
import 'package:net_kit/src/services/mappers/response_classifier.dart';
import 'package:net_kit/src/services/resolver/request_body_content_type_resolver.dart';
import 'package:net_kit/src/services/transformers/request/request_body_transformer.dart';
import 'package:net_kit/src/services/transformers/response/error_response_data_transformer.dart';
import 'package:net_kit/src/services/transformers/response/successful_response_data_transformer.dart';
import 'package:test/test.dart';

class _MockDio extends Mock implements Dio {}

class _MockRequestComposer extends Mock implements RequestComposer {}

class _MockRequestBodyTransformer extends Mock
    implements RequestBodyTransformer {}

class _MockRequestBodyContentTypeResolver extends Mock
    implements RequestBodyContentTypeResolver {}

class _MockDioCancelTokenFactory extends Mock
    implements DioCancelTokenFactory {}

class MockDioRequestOptionsBuilder extends Mock
    implements DioRequestOptionsBuilder {}

class _MockErrorResponseDataTransformer extends Mock
    implements ErrorResponseDataTransformer {}

class _MockSuccessfulResponseDataTransformer extends Mock
    implements SuccessfulResponseDataTransformer {}

class _MockClientExceptionMapper extends Mock
    implements ClientExceptionMapper {}

class _MockResponseCodec extends Mock
    implements ResponseDataCodec<String, String> {}

class _MockResponseClassifier extends Mock implements ResponseClassifier {}

class _FakeRequestSpec extends Fake implements RequestSpec {}

class _FakeRequestOptions extends Fake implements RequestOptions {}

class _FakeResponseContext extends Fake implements ResponseContext {}

void main() {
  late DefaultClientConfig defaultClientConfig;
  late RequestSpec spec;
  late Response<dynamic> defaultResponse;

  late _MockDio mockDio;
  late _MockRequestComposer mockRequestComposer;
  late _MockRequestBodyTransformer mockRequestBodyTransformer;
  late _MockRequestBodyContentTypeResolver mockRequestBodyContentTypeResolver;
  late _MockDioCancelTokenFactory mockDioCancelTokenFactory;
  late MockDioRequestOptionsBuilder mockDioRequestOptionsBuilder;
  late _MockErrorResponseDataTransformer mockErrorResponseDataTransformer;
  late _MockSuccessfulResponseDataTransformer
      mockSuccessfulResponseDataTransformer;
  late _MockClientExceptionMapper mockClientExceptionMapper;
  late _MockResponseCodec mockRequestCodec;
  late _MockResponseClassifier mockResponseClassifier;

  late NetClient sut;

  setUpAll(() {
    registerFallbackValue(_FakeRequestSpec());
    registerFallbackValue(_FakeRequestOptions());
    registerFallbackValue(_FakeResponseContext());
  });

  setUp(() {
    defaultClientConfig = const DefaultClientConfig();
    spec = RequestSpec(
      pathOrUrl: '/users',
      method: HttpMethod.POST,
      body: const JsonBody({'name': 'Alice'}),
      queryParameters: const {'page': 1},
      headers: const {'authorization': 'Bearer token'},
      followRedirects: false,
      maxRedirects: 1,
    );
    defaultResponse = Response<dynamic>(
      requestOptions: RequestOptions(path: spec.pathOrUrl),
      statusCode: 200,
      data: {'id': 1},
    );

    mockDio = _MockDio();
    mockRequestComposer = _MockRequestComposer();
    mockRequestBodyTransformer = _MockRequestBodyTransformer();
    mockRequestBodyContentTypeResolver = _MockRequestBodyContentTypeResolver();
    mockDioCancelTokenFactory = _MockDioCancelTokenFactory();
    mockDioRequestOptionsBuilder = MockDioRequestOptionsBuilder();
    mockErrorResponseDataTransformer = _MockErrorResponseDataTransformer();
    mockSuccessfulResponseDataTransformer =
        _MockSuccessfulResponseDataTransformer();
    mockClientExceptionMapper = _MockClientExceptionMapper();
    mockRequestCodec = _MockResponseCodec();
    mockResponseClassifier = _MockResponseClassifier();

    when(() => mockRequestComposer.compose(spec, defaultClientConfig))
        .thenReturn(spec);
    when(() => mockRequestBodyTransformer.transform(any()))
        .thenReturn({'name': 'Alice'});
    when(() => mockRequestBodyContentTypeResolver.resolve(any()))
        .thenReturn(Headers.jsonContentType);
    when(() => mockDioCancelTokenFactory.create(any(), any())).thenReturn(null);
    when(
      () => mockDioRequestOptionsBuilder.build(
        composedSpec: any(named: 'composedSpec'),
        transformedBody: any(named: 'transformedBody'),
        resolvedContentType: any(named: 'resolvedContentType'),
        cancelToken: any(named: 'cancelToken'),
        onSendProgress: any(named: 'onSendProgress'),
        onReceiveProgress: any(named: 'onReceiveProgress'),
      ),
    ).thenReturn(RequestOptions(path: spec.pathOrUrl));
    when(() => mockDio.fetch<dynamic>(any()))
        .thenAnswer((_) async => defaultResponse);
    when(() => mockResponseClassifier.isError(any())).thenReturn(false);
    when(
      () => mockSuccessfulResponseDataTransformer.transform(
        any<dynamic>(),
        mockRequestCodec,
      ),
    ).thenReturn(Result.success('decoded-response'));

    sut = DioNetClient.test(
      mockDio,
      defaultClientConfig,
      mockRequestComposer,
      mockRequestBodyTransformer,
      mockRequestBodyContentTypeResolver,
      mockDioCancelTokenFactory,
      mockDioRequestOptionsBuilder,
      mockErrorResponseDataTransformer,
      mockSuccessfulResponseDataTransformer,
      mockClientExceptionMapper,
    );
  });

  test(
    'Execute passes spec and defaultClientConfig to RequestComposer',
    () async {
      await sut.execute(
        spec: spec,
        codec: mockRequestCodec,
        responseClassifier: mockResponseClassifier,
      );

      verify(() => mockRequestComposer.compose(spec, defaultClientConfig))
          .called(1);
    },
  );

  test(
    'Execute passes composed body to RequestBodyTransformer',
    () async {
      final composedSpec =
          spec.copyWith(body: const JsonBody({'composed': true}));

      when(() => mockRequestComposer.compose(spec, defaultClientConfig))
          .thenReturn(composedSpec);
      when(() => mockRequestBodyTransformer.transform(composedSpec.body))
          .thenReturn({'name': 'Alice'});

      await sut.execute(spec: spec, codec: mockRequestCodec);

      verify(() => mockRequestBodyTransformer.transform(composedSpec.body))
          .called(1);
    },
  );

  test(
    'Execute passes composed spec and requestCanceller to DioCancelTokenFactory',
    () async {
      final requestCanceller = RequestCanceller();
      final composedSpec =
          spec.copyWith(pathOrUrl: 'https://api.example.com/users');
      final cancelToken = CancelToken();

      when(() => mockRequestComposer.compose(spec, defaultClientConfig))
          .thenReturn(composedSpec);
      when(() =>
              mockDioCancelTokenFactory.create(composedSpec, requestCanceller))
          .thenReturn(cancelToken);

      await sut.execute(
        spec: spec,
        codec: mockRequestCodec,
        requestCanceller: requestCanceller,
      );

      verify(() =>
              mockDioCancelTokenFactory.create(composedSpec, requestCanceller))
          .called(1);
    },
  );

  test(
    'Execute sends null request data and no inferred content type for null body',
    () async {
      final bodylessSpec =
          RequestSpec(pathOrUrl: '/health', method: HttpMethod.GET);
      when(() => mockRequestComposer.compose(bodylessSpec, defaultClientConfig))
          .thenReturn(bodylessSpec);
      when(() => mockRequestBodyTransformer.transform(bodylessSpec.body))
          .thenReturn(null);
      when(() => mockRequestBodyContentTypeResolver.resolve(null))
          .thenReturn(null);

      await sut.execute(
        spec: bodylessSpec,
        codec: mockRequestCodec,
      );

      verify(
        () => mockDioRequestOptionsBuilder.build(
          composedSpec: bodylessSpec,
          transformedBody: null,
          resolvedContentType: null,
          cancelToken: any(named: 'cancelToken'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
        ),
      ).called(1);
    },
  );

  test(
    'Execute returns decoded success payload for non-error response',
    () async {
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: spec.pathOrUrl),
        statusCode: 200,
        data: {'id': 1},
        headers: Headers.fromMap(const {
          'content-type': ['application/json'],
        }),
      );
      when(() => mockDio.fetch<dynamic>(any()))
          .thenAnswer((_) async => response);

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
      expect(result.resultOrNull?.data.resultOrNull, 'decoded-response');
    },
  );

  test(
    'Execute returns decoded error response data for classified error response',
    () async {
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

      when(() => mockDio.fetch<dynamic>(any()))
          .thenAnswer((_) async => response);
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
    'Execute returns ParseException for undecodable classified error body',
    () async {
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

      when(() => mockDio.fetch<dynamic>(any()))
          .thenAnswer((_) async => response);
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
    'Execute returns ParseException for undecodable success body',
    () async {
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

      when(() => mockDio.fetch<dynamic>(any()))
          .thenAnswer((_) async => response);
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
      when(() => mockDio.fetch<dynamic>(any())).thenThrow(exception);
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
      when(() => mockDio.fetch<dynamic>(any())).thenThrow(exception);
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

  test(
    'Execute passes progress listeners through the execution flow',
    () async {
      void onSendProgress(_, __) {}

      void onReceiveProgress(_, __) {}

      await sut.execute(
        spec: spec,
        codec: mockRequestCodec,
        responseClassifier: mockResponseClassifier,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      verify(
        () => mockDioRequestOptionsBuilder.build(
          composedSpec: any(named: 'composedSpec'),
          transformedBody: any(named: 'transformedBody'),
          resolvedContentType: any(named: 'resolvedContentType'),
          cancelToken: any(named: 'cancelToken'),
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        ),
      ).called(1);
    },
  );

  test(
    'DioNetClient.close delegates to Dio.close',
    () {
      final client = DioNetClient();

      client.close();
    },
  );
}
