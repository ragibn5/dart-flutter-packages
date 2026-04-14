// ignore_for_file: lines_longer_than_80_chars, avoid_redundant_argument_values

import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_kit/src/enums/network_exception_type.dart';
import 'package:net_kit/src/enums/parse_target_type.dart';
import 'package:net_kit/src/models/http_method.dart';
import 'package:net_kit/src/models/net_kit_exception.dart';
import 'package:net_kit/src/models/request_spec.dart';
import 'package:net_kit/src/models/result.dart';
import 'package:net_kit/src/net_kit.dart';
import 'package:net_kit/src/services/client_exception_mapper.dart';
import 'package:net_kit/src/services/codec/net_kit_request_encoder.dart';
import 'package:net_kit/src/services/codec/net_kit_response_decoder.dart';
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

void main() {
  late MockDio mockDio;
  late MockRequestEncoder mockRequestEncoder;
  late MockResponseDecoder mockErrorResponseDecoder;
  late MockResponseDecoder mockSuccessfulResponseDecoder;
  late MockClientExceptionMapper mockClientExceptionMapper;
  late MockRequestCodec mockRequestCodec;
  late MockResponseClassifier mockResponseClassifier;
  late NetKit sut;
  late RequestSpec<String, String, String> spec;

  setUpAll(() {
    registerFallbackValue(FakeOptions());
    registerFallbackValue(FakeRequestOptions());
  });

  setUp(() {
    mockDio = MockDio();
    mockRequestEncoder = MockRequestEncoder();
    mockErrorResponseDecoder = MockResponseDecoder();
    mockSuccessfulResponseDecoder = MockResponseDecoder();
    mockClientExceptionMapper = MockClientExceptionMapper();
    mockRequestCodec = MockRequestCodec();
    mockResponseClassifier = MockResponseClassifier();

    sut = NetKit.test(
      mockDio,
      mockRequestEncoder,
      mockErrorResponseDecoder,
      mockSuccessfulResponseDecoder,
      mockClientExceptionMapper,
    );

    spec = RequestSpec<String, String, String>(
      path: '/users',
      method: HttpMethod.POST,
      body: 'request-body',
      codec: mockRequestCodec,
      responseClassifier: mockResponseClassifier,
      queryParameters: const {'page': 1},
      headers: const {'authorization': 'Bearer token'},
    );

    when(
      () => mockRequestEncoder.encode<String>(spec.body, any()),
    ).thenReturn(Result.success(null));
  });

  test('execute returns request encoder error without calling Dio', () async {
    const parseException = ParseException(
      targetType: ParseTargetType.REQUEST_ENCODE,
      data: 'request-body',
    );

    when(
      () => mockRequestEncoder.encode<String>('request-body', any()),
    ).thenReturn(Result.error(parseException));

    final result = await sut.execute(spec);

    expect(result.isError, isTrue);
    expect(result.errorOrNull, same(parseException));
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
  });

  test('execute returns decoded success for non-error response', () async {
    const encodedBody = {'name': 'Alice'};
    const responseData = {'id': 1};
    const decodedResponse = 'decoded-response';
    final cancelToken = CancelToken();
    final response = Response<dynamic>(
      requestOptions: RequestOptions(path: spec.path),
      data: responseData,
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
        cancelToken: cancelToken,
        options: any(named: 'options'),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    ).thenAnswer((_) async => response);
    when(() => mockResponseClassifier.isError(response)).thenReturn(false);
    when(
      () => mockSuccessfulResponseDecoder.decode<String>(
        responseData,
        any(),
      ),
    ).thenReturn(Result.success(decodedResponse));

    final result = await sut.execute(
      spec,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    expect(result.isSuccess, isTrue);
    expect(result.resultOrNull, decodedResponse);
    final capturedOptions = verify(
      () => mockDio.request<dynamic>(
        spec.path,
        data: encodedBody,
        queryParameters: spec.queryParameters,
        cancelToken: cancelToken,
        options: captureAny(named: 'options'),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    ).captured.single as Options;
    expect(capturedOptions.method, spec.method.value);
    expect(capturedOptions.headers, spec.headers);
  });

  test(
      'execute returns DomainException for classified error with decodable error body',
      () async {
    const responseData = {'code': 'invalid'};
    const decodedError = 'decoded-error';
    final response = Response<dynamic>(
      requestOptions: RequestOptions(path: spec.path),
      data: responseData,
    );

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
    when(() => mockResponseClassifier.isError(response)).thenReturn(true);
    when(
      () => mockErrorResponseDecoder.decode<String>(responseData, any()),
    ).thenReturn(Result.success(decodedError));

    final result = await sut.execute(spec);

    expect(
      result.errorOrNull,
      isA<DomainException<String>>().having(
        (p) => p.error,
        'error',
        decodedError,
      ),
    );
  });

  test(
      'execute returns decoder ParseException for classified error with undecodable error body',
      () async {
    const responseData = {'code': 'invalid'};
    const parseException = ParseException(
      targetType: ParseTargetType.ERROR_DECODE,
      data: responseData,
    );
    final response = Response<dynamic>(
      requestOptions: RequestOptions(path: spec.path),
      data: responseData,
    );

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
    when(() => mockResponseClassifier.isError(response)).thenReturn(true);
    when(
      () => mockErrorResponseDecoder.decode<String>(responseData, any()),
    ).thenReturn(Result.error(parseException));

    final result = await sut.execute(spec);

    expect(result.isError, isTrue);
    expect(result.errorOrNull, same(parseException));
  });

  test('execute maps thrown exception with client exception mapper', () async {
    final exception = DioException(
      requestOptions: RequestOptions(path: spec.path),
      type: DioExceptionType.connectionError,
    );
    const mappedException = NetworkException(
      NetworkExceptionType.CONNECTION_ERROR,
    );

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
    ).thenReturn(mappedException);

    final result = await sut.execute(spec);

    expect(result.isError, isTrue);
    expect(result.errorOrNull, same(mappedException));
  });

  test('executeRaw delegates to Dio.request', () async {
    final cancelToken = CancelToken();
    final options = Options(method: 'PATCH');
    final response = Response<dynamic>(
      requestOptions: RequestOptions(path: '/raw'),
      data: 'raw-data',
    );

    when(
      () => mockDio.request<dynamic>(
        '/raw',
        data: 'payload',
        queryParameters: const {'page': 1},
        cancelToken: cancelToken,
        options: options,
        onSendProgress: null,
        onReceiveProgress: null,
      ),
    ).thenAnswer((_) async => response);

    final result = await sut.executeRaw(
      '/raw',
      data: 'payload',
      queryParameters: const {'page': 1},
      options: options,
      cancelToken: cancelToken,
    );

    expect(result, same(response));
  });

  test('executeRawWithOptions delegates to Dio.fetch', () async {
    final requestOptions = RequestOptions(path: '/raw');
    final response = Response<dynamic>(
      requestOptions: requestOptions,
      data: 'raw-data',
    );

    when(
      () => mockDio.fetch<dynamic>(requestOptions),
    ).thenAnswer((_) async => response);

    final result = await sut.executeRawWithOptions(requestOptions);

    expect(result, same(response));
  });

  test('download delegates to Dio.download', () async {
    final cancelToken = CancelToken();
    final options = Options();
    final response = Response<dynamic>(
      requestOptions: RequestOptions(path: '/file'),
      data: 'saved',
    );

    when(
      () => mockDio.download(
        '/file',
        '/tmp/file',
        onReceiveProgress: null,
        queryParameters: const {'page': 1},
        cancelToken: cancelToken,
        deleteOnError: false,
        fileAccessMode: FileAccessMode.append,
        lengthHeader: 'content-length',
        data: 'payload',
        options: options,
      ),
    ).thenAnswer((_) async => response);

    final result = await sut.download(
      '/file',
      '/tmp/file',
      queryParameters: const {'page': 1},
      cancelToken: cancelToken,
      deleteOnError: false,
      fileAccessMode: FileAccessMode.append,
      lengthHeader: 'content-length',
      data: 'payload',
      options: options,
    );

    expect(result, same(response));
  });

  test('downloadUri delegates to Dio.downloadUri', () async {
    final uri = Uri.parse('https://example.com/file');
    final cancelToken = CancelToken();
    final options = Options();
    final response = Response<dynamic>(
      requestOptions: RequestOptions(path: uri.toString()),
      data: 'saved',
    );

    when(
      () => mockDio.downloadUri(
        uri,
        '/tmp/file',
        onReceiveProgress: null,
        cancelToken: cancelToken,
        deleteOnError: false,
        fileAccessMode: FileAccessMode.append,
        lengthHeader: 'content-length',
        data: 'payload',
        options: options,
      ),
    ).thenAnswer((_) async => response);

    final result = await sut.downloadUri(
      uri,
      '/tmp/file',
      cancelToken: cancelToken,
      deleteOnError: false,
      fileAccessMode: FileAccessMode.append,
      lengthHeader: 'content-length',
      data: 'payload',
      options: options,
    );

    expect(result, same(response));
  });

  test('close delegates to Dio.close', () {
    when(() => mockDio.close()).thenReturn(null);

    sut.close();

    verify(() => mockDio.close()).called(1);
  });
}
