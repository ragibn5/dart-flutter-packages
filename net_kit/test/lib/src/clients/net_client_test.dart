// ignore_for_file: lines_longer_than_80_chars, avoid_redundant_argument_values, cascade_invocations

import 'package:mocktail/mocktail.dart';
import 'package:net_kit/net_kit.dart';
import 'package:net_kit/src/clients/net_client_impl.dart';
import 'package:net_kit/src/services/adapters/network_request_adapter.dart';
import 'package:net_kit/src/services/composer/request_composer.dart';
import 'package:test/test.dart';

class _MockNetworkRequestAdapter extends Mock
    implements NetworkRequestAdapter {}

class _MockRequestComposer extends Mock implements RequestComposer {}

class _MockNetKitInterceptor extends Mock implements NetKitInterceptor {}

class _MockResponseClassifier extends Mock implements ResponseClassifier {}

void main() {
  const clientConfig = ClientConfig(baseUrl: 'https://api.example.com');
  final spec = RequestSpec(pathOrUrl: '/users', method: HttpMethod.GET);
  final composedSpec = RequestSpec(
    pathOrUrl: 'https://api.example.com/users',
    method: HttpMethod.GET,
    baseUrl: 'https://api.example.com',
  );
  final netKitException = TransportException(
    type: TransportExceptionType.CONNECTION_ERROR,
    request: composedSpec,
  );
  final rawResponse = RawResponse(
    statusCode: 200,
    request: composedSpec,
    rawResponseBody: {'id': 1},
    responseHeaders: {
      'content-type': ['application/json']
    },
  );
  final errorResponse = RawResponse(
    statusCode: 404,
    request: composedSpec,
    rawResponseBody: {'error': 'Not found'},
    responseHeaders: {
      'content-type': ['application/json']
    },
  );
  void sendListener(int count, int total) {}
  void receiveListener(int count, int total) {}

  late _MockNetworkRequestAdapter mockRequestAdapter;
  late _MockRequestComposer mockRequestComposer;
  late _MockNetKitInterceptor mockInterceptor;
  late _MockResponseClassifier mockResponseClassifier;

  late NetClient sut;

  setUpAll(() {
    registerFallbackValue(spec);
    registerFallbackValue(rawResponse);
    registerFallbackValue(clientConfig);
    registerFallbackValue(netKitException);
  });

  setUp(() {
    mockRequestAdapter = _MockNetworkRequestAdapter();
    mockRequestComposer = _MockRequestComposer();
    mockInterceptor = _MockNetKitInterceptor();
    mockResponseClassifier = _MockResponseClassifier();

    sut = NetClientImpl(
      clientConfig: clientConfig,
      interceptors: [mockInterceptor],
      requestAdapter: mockRequestAdapter,
      requestComposer: mockRequestComposer,
    );

    when(() => mockRequestComposer.compose(any(), any()))
        .thenReturn(composedSpec);
    when(() => mockInterceptor.onRequest(any()))
        .thenAnswer((_) async => ContinueWithRequest(spec));
    when(() => mockInterceptor.onResponse(any())).thenAnswer(
        (invocation) async => ContinueWithResponse(
            invocation.positionalArguments.first as RawResponse));
    when(() => mockInterceptor.onError(any()))
        .thenAnswer((_) async => ContinueWithError(netKitException));
    when(() => mockResponseClassifier.isError(any())).thenReturn(false);
    when(
      () => mockRequestAdapter.performRequest(
        spec: any(named: 'spec'),
        onSendProgress: any(named: 'onSendProgress'),
        onReceiveProgress: any(named: 'onReceiveProgress'),
        requestCanceller: any(named: 'requestCanceller'),
      ),
    ).thenAnswer((_) async => Result.success(rawResponse));
  });

  test('execute returns success when request and response succeed', () async {
    final result = await sut.execute(
      spec: spec,
      onSendProgress: sendListener,
      onReceiveProgress: receiveListener,
      responseClassifier: mockResponseClassifier,
    );

    expect(
      result,
      isA<Result<NetKitException, NetKitResponse>>()
          .having((p) => p.isSuccess, 'isSuccess', true)
          .having((p) => p.resultOrNull, 'resultOrNull', isNotNull),
    );
    expect(result.resultOrNull!.isError, false);
    expect(result.resultOrNull!.statusCode, 200);
    expect(result.resultOrNull!.data, {'id': 1});
  });

  test(
    'execute calls requestComposer.compose with spec and clientConfig',
    () async {
      await sut.execute(spec: spec, responseClassifier: mockResponseClassifier);

      verify(() => mockRequestComposer.compose(spec, clientConfig)).called(1);
    },
  );

  test(
    'execute returns error when request interceptor returns RejectRequest',
    () async {
      final rejectError = TransportException(
        type: TransportExceptionType.BAD_CERTIFICATE,
        request: composedSpec,
      );
      when(() => mockInterceptor.onRequest(any()))
          .thenAnswer((_) async => RejectRequest(rejectError));

      final result = await sut.execute(
        spec: spec,
        responseClassifier: mockResponseClassifier,
      );

      expect(
        result,
        isA<Result<NetKitException, NetKitResponse>>()
            .having((p) => p.isError, 'isError', true)
            .having((p) => p.errorOrNull, 'errorOrNull', rejectError),
      );
      verifyNever(
        () => mockRequestAdapter.performRequest(
          spec: any(named: 'spec'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
          requestCanceller: any(named: 'requestCanceller'),
        ),
      );
    },
  );

  test(
    'execute returns success when request interceptor returns ResolveRequest',
    () async {
      when(() => mockInterceptor.onRequest(any()))
          .thenAnswer((_) async => ResolveRequest(rawResponse));

      final result = await sut.execute(
        spec: spec,
        responseClassifier: mockResponseClassifier,
      );

      expect(
        result,
        isA<Result<NetKitException, NetKitResponse>>()
            .having((p) => p.isSuccess, 'isSuccess', true)
            .having((p) => p.resultOrNull!.statusCode, 'statusCode', 200),
      );
      verifyNever(() => mockRequestAdapter.performRequest(
            spec: any(named: 'spec'),
            onSendProgress: any(named: 'onSendProgress'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
            requestCanceller: any(named: 'requestCanceller'),
          ));
    },
  );

  test(
    'execute passes modified spec when interceptor returns ContinueWithRequest',
    () async {
      final modifiedSpec =
          composedSpec.copyWith(headers: {'x-custom': 'value'});
      when(() => mockInterceptor.onRequest(any()))
          .thenAnswer((_) async => ContinueWithRequest(modifiedSpec));

      await sut.execute(spec: spec, responseClassifier: mockResponseClassifier);

      verify(
        () => mockRequestAdapter.performRequest(
          spec: modifiedSpec,
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
          requestCanceller: any(named: 'requestCanceller'),
        ),
      ).called(1);
    },
  );

  test(
    'execute returns error when response interceptor returns RejectResponse',
    () async {
      final rejectError = TransportException(
        type: TransportExceptionType.BAD_CERTIFICATE,
        request: composedSpec,
      );
      when(() => mockInterceptor.onResponse(any()))
          .thenAnswer((_) async => RejectResponse(rejectError));

      final result = await sut.execute(
        spec: spec,
        responseClassifier: mockResponseClassifier,
      );

      expect(
        result,
        isA<Result<NetKitException, NetKitResponse>>()
            .having((p) => p.isError, 'isError', true)
            .having((p) => p.errorOrNull, 'errorOrNull', rejectError),
      );
    },
  );

  test(
    'execute returns success when response interceptor returns ResolveResponse',
    () async {
      when(() => mockInterceptor.onResponse(any()))
          .thenAnswer((_) async => ResolveResponse(rawResponse));

      final result = await sut.execute(
        spec: spec,
        responseClassifier: mockResponseClassifier,
      );

      expect(
        result,
        isA<Result<NetKitException, NetKitResponse>>()
            .having((p) => p.isSuccess, 'isSuccess', true),
      );
    },
  );

  test(
    'execute passes modified response when interceptor returns ContinueWithResponse',
    () async {
      final modifiedResponse = RawResponse(
        statusCode: 201,
        rawResponseBody: {'id': 2, 'created': true},
        responseHeaders: {
          'content-type': ['application/json']
        },
        request: composedSpec,
      );
      when(() => mockInterceptor.onResponse(any()))
          .thenAnswer((_) async => ContinueWithResponse(modifiedResponse));

      final result = await sut.execute(
        spec: spec,
        responseClassifier: mockResponseClassifier,
      );

      expect(result.resultOrNull!.statusCode, 201);
      expect(result.resultOrNull!.data, {'id': 2, 'created': true});
    },
  );

  test('execute returns error when performRequest returns error', () async {
    when(() => mockRequestAdapter.performRequest(
          spec: any(named: 'spec'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
          requestCanceller: any(named: 'requestCanceller'),
        )).thenAnswer(
      (_) async => Result.error(netKitException),
    );

    final result = await sut.execute(
      spec: spec,
      responseClassifier: mockResponseClassifier,
    );

    expect(
      result,
      isA<Result<NetKitException, NetKitResponse>>()
          .having((p) => p.isError, 'isError', true)
          .having((p) => p.errorOrNull, 'errorOrNull', netKitException),
    );
  });

  test(
    'execute returns error when error interceptor returns RejectError',
    () async {
      final rejectedError = TransportException(
        type: TransportExceptionType.BAD_CERTIFICATE,
        request: composedSpec,
      );
      when(() => mockRequestAdapter.performRequest(
            spec: any(named: 'spec'),
            onSendProgress: any(named: 'onSendProgress'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
            requestCanceller: any(named: 'requestCanceller'),
          )).thenAnswer(
        (_) async => Result.error(netKitException),
      );
      when(() => mockInterceptor.onError(any()))
          .thenAnswer((_) async => RejectError(rejectedError));

      final result = await sut.execute(
        spec: spec,
        responseClassifier: mockResponseClassifier,
      );

      expect(
        result,
        isA<Result<NetKitException, NetKitResponse>>()
            .having((p) => p.isError, 'isError', true)
            .having((p) => p.errorOrNull, 'errorOrNull', rejectedError),
      );
    },
  );

  test(
    'execute returns success when error interceptor returns RecoverError',
    () async {
      when(() => mockRequestAdapter.performRequest(
            spec: any(named: 'spec'),
            onSendProgress: any(named: 'onSendProgress'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
            requestCanceller: any(named: 'requestCanceller'),
          )).thenAnswer(
        (_) async => Result.error(netKitException),
      );
      when(() => mockInterceptor.onError(any()))
          .thenAnswer((_) async => RecoverError(rawResponse));

      final result = await sut.execute(
        spec: spec,
        responseClassifier: mockResponseClassifier,
      );

      expect(
        result,
        isA<Result<NetKitException, NetKitResponse>>()
            .having((p) => p.isSuccess, 'isSuccess', true),
      );
    },
  );

  test(
    'execute passes modified error when interceptor returns ContinueWithError',
    () async {
      final modifiedError = TransportException(
        type: TransportExceptionType.SEND_TIMEOUT,
        request: composedSpec,
      );
      when(() => mockRequestAdapter.performRequest(
            spec: any(named: 'spec'),
            onSendProgress: any(named: 'onSendProgress'),
            onReceiveProgress: any(named: 'onReceiveProgress'),
            requestCanceller: any(named: 'requestCanceller'),
          )).thenAnswer(
        (_) async => Result.error(netKitException),
      );
      when(() => mockInterceptor.onError(any()))
          .thenAnswer((_) async => ContinueWithError(modifiedError));

      final result = await sut.execute(
        spec: spec,
        responseClassifier: mockResponseClassifier,
      );

      expect(
        result,
        isA<Result<NetKitException, NetKitResponse>>()
            .having((p) => p.isError, 'isError', true)
            .having((p) => p.errorOrNull, 'errorOrNull', modifiedError),
      );
    },
  );

  test('execute uses responseClassifier to determine isError', () async {
    when(() => mockResponseClassifier.isError(any())).thenReturn(true);

    final result = await sut.execute(
      spec: spec,
      responseClassifier: mockResponseClassifier,
    );

    expect(result.resultOrNull!.isError, true);
    verify(() => mockResponseClassifier.isError(rawResponse))
        .called(greaterThan(0));
  });

  test('execute handles multiple interceptors in order', () async {
    final interceptor2 = _MockNetKitInterceptor();
    when(() => interceptor2.onRequest(any()))
        .thenAnswer((_) async => ContinueWithRequest(spec));
    when(() => interceptor2.onResponse(any()))
        .thenAnswer((_) async => ContinueWithResponse(rawResponse));
    when(() => interceptor2.onError(any()))
        .thenAnswer((_) async => ContinueWithError(netKitException));

    final multiInterceptorSut = NetClientImpl(
      clientConfig: clientConfig,
      interceptors: [mockInterceptor, interceptor2],
      requestAdapter: mockRequestAdapter,
      requestComposer: mockRequestComposer,
    );

    await multiInterceptorSut.execute(
      spec: spec,
      responseClassifier: mockResponseClassifier,
    );

    verify(() => mockInterceptor.onRequest(any())).called(greaterThan(0));
    verify(() => interceptor2.onRequest(any())).called(greaterThan(0));
    verify(() => mockInterceptor.onResponse(any())).called(greaterThan(0));
    verify(() => interceptor2.onResponse(any())).called(greaterThan(0));
  });

  test('execute uses default ResponseClassifier when not provided', () async {
    when(() => mockRequestAdapter.performRequest(
          spec: any(named: 'spec'),
          onSendProgress: any(named: 'onSendProgress'),
          onReceiveProgress: any(named: 'onReceiveProgress'),
          requestCanceller: any(named: 'requestCanceller'),
        )).thenAnswer(
      (_) async => Result.success(errorResponse),
    );

    final result = await sut.execute(spec: spec);

    expect(result.resultOrNull!.isError, true);
    expect(result.resultOrNull!.statusCode, 404);
  });

  test('close calls requestAdapter.close', () {
    when(() => mockRequestAdapter.close()).thenAnswer((_) {});

    sut.close();

    verify(() => mockRequestAdapter.close()).called(1);
  });
}
