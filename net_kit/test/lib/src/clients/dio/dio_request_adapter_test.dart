// ignore_for_file: lines_longer_than_80_chars, avoid_redundant_argument_values, cascade_invocations

import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_kit/net_kit.dart';
import 'package:net_kit/src/clients/dio/dio_exception_mapper.dart';
import 'package:net_kit/src/clients/dio/dio_request_adapter.dart';
import 'package:net_kit/src/clients/dio/dio_request_options_builder.dart';
import 'package:test/test.dart';

class _MockDio extends Mock implements Dio {}

class _MockDioExceptionMapper extends Mock implements DioExceptionMapper {}

class _MockDioRequestOptionsBuilder extends Mock
    implements DioRequestOptionsBuilder {}

void main() {
  const path = '/users';
  const data = {'uid': 123};
  const rawHeaders = <String, List<String>>{
    'content-type': ['application/json'],
  };
  const transportExpType = TransportExceptionType.CONNECTION_ERROR;
  final errorCause = Object();
  final stackTrace = StackTrace.current;
  final dioHeaders = Headers.fromMap(rawHeaders);
  final requestOptions = RequestOptions(path: path);
  final rawResponse = Response<dynamic>(
    requestOptions: requestOptions,
    statusCode: 200,
    headers: dioHeaders,
    data: data,
  );
  final requestCanceller = RequestCanceller();
  final spec = RequestSpec(
    pathOrUrl: path,
    method: HttpMethod.POST,
    body: const JsonBody({'name': 'Alice'}),
    queryParameters: {'page': 1},
    headers: {'authorization': 'Bearer token'},
    followRedirects: false,
    maxRedirects: 1,
  );
  final netKitException = TransportException(
    type: transportExpType,
    request: spec,
    cause: errorCause,
    stackTrace: stackTrace,
  );
  void sendListener(int count, int total) {}
  void receiveListener(int count, int total) {}

  late _MockDio mockDio;
  late _MockDioExceptionMapper mockDioExceptionMapper;
  late _MockDioRequestOptionsBuilder mockDioRequestOptionsBuilder;

  late DioRequestAdapter sut;

  setUpAll(() {
    registerFallbackValue(spec);
  });

  setUp(() {
    mockDio = _MockDio();
    mockDioExceptionMapper = _MockDioExceptionMapper();
    mockDioRequestOptionsBuilder = _MockDioRequestOptionsBuilder();

    sut = DioRequestAdapter.test(
      mockDio,
      mockDioExceptionMapper,
      mockDioRequestOptionsBuilder,
    );

    when(
      () => mockDioRequestOptionsBuilder.build(
        spec: spec,
        canceller: requestCanceller,
        onSendProgress: sendListener,
        onReceiveProgress: receiveListener,
      ),
    ).thenReturn(requestOptions);
    when(() => mockDio.fetch<dynamic>(requestOptions))
        .thenAnswer((_) async => rawResponse);
    when(
      () => mockDioExceptionMapper.mapException(
        request: any(named: 'request'),
        exception: errorCause,
        stackTrace: stackTrace,
      ),
    ).thenReturn(netKitException);
    when(() => mockDio.close()).thenAnswer((_) {});
  });

  test(
    'performRequest passes spec and other params to DioRequestOptionsBuilder',
    () async {
      await sut.performRequest(
        spec: spec,
        onSendProgress: sendListener,
        onReceiveProgress: receiveListener,
        requestCanceller: requestCanceller,
      );

      verify(
        () => mockDioRequestOptionsBuilder.build(
          spec: spec,
          canceller: requestCanceller,
          onSendProgress: sendListener,
          onReceiveProgress: receiveListener,
        ),
      ).called(1);
    },
  );

  test(
    'performRequest returns RawResponse with correct values if succeeded',
    () async {
      final result = await sut.performRequest(
        spec: spec,
        requestCanceller: requestCanceller,
        onSendProgress: sendListener,
        onReceiveProgress: receiveListener,
      );

      expect(
          result,
          isA<Result<NetKitException, RawResponse>>()
              .having((p) => p.isError, 'isError', false)
              .having((p) => p.resultOrThrow, 'resultOrNull', isNotNull)
              .having((p) => p.resultOrThrow.statusCode, 'statusCode',
                  rawResponse.statusCode)
              .having((p) => p.resultOrThrow.responseHeaders, 'responseHeaders',
                  rawResponse.headers.map)
              .having((p) => p.resultOrThrow.rawResponseBody, 'rawResponseBody',
                  rawResponse.data)
              .having((p) => p.resultOrThrow.request, 'request', spec));
    },
  );

  test(
    'performRequest returns NetKitException returned by DioExceptionMapper',
    () async {
      when(() => mockDio.fetch<dynamic>(requestOptions))
          .thenAnswer((_) => Future.error(errorCause, stackTrace));

      final result = await sut.performRequest(
        spec: spec,
        requestCanceller: requestCanceller,
        onSendProgress: sendListener,
        onReceiveProgress: receiveListener,
      );

      expect(
        result,
        isA<Result<NetKitException, RawResponse>>()
            .having((p) => p.isError, 'isError', true)
            .having((p) => p.errorOrThrow, 'errorOrNull', netKitException)
            .having((p) => p.errorOrThrow.cause, 'cause', errorCause)
            .having((p) => p.errorOrThrow.stackTrace, 'stackTrace', stackTrace),
      );
    },
  );

  test(
    'close() closes Dio',
    () async {
      sut.close();

      verify(() => mockDio.close()).called(1);
    },
  );
}
