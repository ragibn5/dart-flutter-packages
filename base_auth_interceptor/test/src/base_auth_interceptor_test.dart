import 'dart:typed_data';

import 'package:base_auth_interceptor/base_auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockAuthDataProvider extends Mock implements AuthDataProvider<String> {}

class _MockAuthRefreshPolicy extends Mock
    implements AuthRefreshPolicy<String> {}

class _MockAuthRequestTransformer extends Mock
    implements AuthRequestTransformer<String> {}

class _MockRequestRetrier extends Mock implements RequestRetrier {}

class _TestAuthInterceptor extends BaseAuthInterceptor<String> {
  _TestAuthInterceptor(
    super.authDataProvider,
    super.refreshPolicy,
    super.requestTransformer,
    super.requestRetrier,
  );
}

/// Answers every request with [respond], and records what it was sent.
class _FakeAdapter implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions) respond;
  final requests = <RequestOptions>[];

  _FakeAdapter(this.respond);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

const _authHeader = 'Authorization';

String? _authOf(RequestOptions request) =>
    request.headers[_authHeader] as String?;

void main() {
  late _MockAuthDataProvider provider;
  late _MockAuthRefreshPolicy policy;
  late _MockAuthRequestTransformer transformer;
  late _MockRequestRetrier retrier;

  setUpAll(() {
    registerFallbackValue(RequestOptions());
    registerFallbackValue(Response<dynamic>(requestOptions: RequestOptions()));
  });

  setUp(() {
    provider = _MockAuthDataProvider();
    policy = _MockAuthRefreshPolicy();
    transformer = _MockAuthRequestTransformer();
    retrier = _MockRequestRetrier();

    when(() => provider.getAuthData()).thenAnswer((_) async => 'old');
    when(
      () => policy.didServerReportAuthError(any()),
    ).thenAnswer(
        (i) => (i.positionalArguments[0] as Response).statusCode == 401);
    when(() => policy.shouldRefreshAuthData(any(), any())).thenReturn(true);
    when(() => transformer.transformRequestWithAuthData(any(), any()))
        .thenAnswer(
      (i) async {
        final request = i.positionalArguments[0] as RequestOptions;
        final authData = i.positionalArguments[1] as String;
        return request.copyWith(
          headers: {...request.headers, _authHeader: 'Bearer $authData'},
        );
      },
    );
    when(() => retrier.retryRequest(any())).thenAnswer(
      (i) async => Response<dynamic>(
        requestOptions: i.positionalArguments[0] as RequestOptions,
        statusCode: 200,
        data: 'retried',
      ),
    );
  });

  Dio buildDio(
    _FakeAdapter adapter, {
    ValidateStatus? validateStatus,
  }) {
    return Dio(
      BaseOptions(
        baseUrl: 'https://example.com',
        validateStatus: validateStatus,
      ),
    )
      ..httpClientAdapter = adapter
      ..interceptors.add(
        _TestAuthInterceptor(provider, policy, transformer, retrier),
      );
  }

  _FakeAdapter respondWith(int statusCode) =>
      _FakeAdapter((_) => ResponseBody.fromString('sent', statusCode));

  Future<DioException> requestError(Dio dio) async {
    try {
      await dio.get<dynamic>('/a');
    } on DioException catch (e) {
      return e;
    }
    throw StateError('The request should have failed');
  }

  test('requestShouldBeSentWithTheAuthDataIfItIsAvailable', () async {
    final adapter = respondWith(200);

    await buildDio(adapter).get<dynamic>('/a');

    expect(_authOf(adapter.requests.single), 'Bearer old');
  });

  test(
    'requestShouldBeCancelledAsAuthDataUnavailableIfThereIsNoAuthData',
    () async {
      when(() => provider.getAuthData()).thenAnswer((_) async => null);
      final adapter = respondWith(200);

      final error = await requestError(buildDio(adapter));

      expect(error.type, DioExceptionType.cancel);
      expect(
        (error.error! as AuthRecoveryException).reason,
        AuthRecoveryFailure.authDataUnavailable,
      );
      expect(adapter.requests, isEmpty);
    },
  );

  test('requestShouldFailWithTheCauseIfTheAuthDataCannotBeRead', () async {
    final cause = Exception('unreadable');
    when(() => provider.getAuthData()).thenThrow(cause);

    final error = await requestError(buildDio(respondWith(200)));

    expect(error.type, DioExceptionType.unknown);
    expect(error.error, cause);
  });

  test('responseShouldPassThroughIfItIsNotAnAuthError', () async {
    final response = await buildDio(respondWith(200)).get<dynamic>('/a');

    expect(response.data, 'sent');
    verifyNever(() => retrier.retryRequest(any()));
  });

  test('errorShouldPassThroughIfItIsNotAnAuthError', () async {
    final error = await requestError(buildDio(respondWith(500)));

    expect(error.type, DioExceptionType.badResponse);
    expect(error.response?.statusCode, 500);
    verifyNever(() => retrier.retryRequest(any()));
  });

  test('errorShouldPassThroughIfThereIsNoResponse', () async {
    final adapter = _FakeAdapter(
      (o) => throw DioException.connectionError(
        requestOptions: o,
        reason: 'offline',
      ),
    );

    final error = await requestError(buildDio(adapter));

    expect(error.type, DioExceptionType.connectionError);
    verifyNever(() => retrier.retryRequest(any()));
  });

  test('authErrorShouldRefreshAndRetryIfTheAuthDataIsStale', () async {
    when(
      () => provider.requestAuthDataRefresh('old'),
    ).thenAnswer((_) async => 'new');

    final response = await buildDio(respondWith(401)).get<dynamic>('/a');

    expect(response.data, 'retried');
    final retried = verify(() => retrier.retryRequest(captureAny())).captured;
    expect(_authOf(retried.single as RequestOptions), 'Bearer new');
  });

  test('authErrorShouldRetryWithoutRefreshingIfTheAuthDataIsCurrent', () async {
    when(() => policy.shouldRefreshAuthData(any(), any())).thenReturn(false);

    final response = await buildDio(respondWith(401)).get<dynamic>('/a');

    expect(response.data, 'retried');
    verifyNever(() => provider.requestAuthDataRefresh(any()));
    final retried = verify(() => retrier.retryRequest(captureAny())).captured;
    expect(_authOf(retried.single as RequestOptions), 'Bearer old');
  });

  test(
    'authErrorShouldBeCancelledAsAuthDataUnavailableIfTheAuthDataIsGone',
    () async {
      final authData = ['old', null];
      when(
        () => provider.getAuthData(),
      ).thenAnswer((_) async => authData.removeAt(0));

      final error = await requestError(buildDio(respondWith(401)));

      expect(error.type, DioExceptionType.cancel);
      expect(
        (error.error! as AuthRecoveryException).reason,
        AuthRecoveryFailure.authDataUnavailable,
      );
      verifyNever(() => retrier.retryRequest(any()));
    },
  );

  test('authErrorShouldBeCancelledAsRefreshFailedIfTheRefreshFails', () async {
    when(
      () => provider.requestAuthDataRefresh('old'),
    ).thenAnswer((_) async => null);

    final error = await requestError(buildDio(respondWith(401)));

    expect(error.type, DioExceptionType.cancel);
    expect(
      (error.error! as AuthRecoveryException).reason,
      AuthRecoveryFailure.refreshFailed,
    );
    verifyNever(() => retrier.retryRequest(any()));
  });

  test('authErrorShouldBeCancelledAsRetryFailedIfTheRetryFails', () async {
    when(
      () => provider.requestAuthDataRefresh('old'),
    ).thenAnswer((_) async => 'new');
    final cause = DioException(requestOptions: RequestOptions());
    when(() => retrier.retryRequest(any())).thenThrow(cause);

    final error = await requestError(buildDio(respondWith(401)));

    expect(error.type, DioExceptionType.cancel);
    final exception = error.error! as AuthRecoveryException;
    expect(exception.reason, AuthRecoveryFailure.retryFailed);
    expect(exception.cause, cause);
  });

  test(
    'authErrorShouldBeRecoveredIfItArrivesAsAResponseTheStatusCheckAccepts',
    () async {
      when(
        () => provider.requestAuthDataRefresh('old'),
      ).thenAnswer((_) async => 'new');
      final dio = buildDio(respondWith(401), validateStatus: (_) => true);

      final response = await dio.get<dynamic>('/a');

      expect(response.data, 'retried');
    },
  );

  test(
    'concurrentAuthErrorsShouldRefreshOnceIfTheFirstRefreshUpdatesTheAuthData',
    () async {
      var authData = 'old';
      when(() => provider.getAuthData()).thenAnswer((_) async => authData);
      when(() => provider.requestAuthDataRefresh(any())).thenAnswer((_) async {
        return authData = 'new';
      });
      // Refresh only if the request was sent with the current auth data.
      when(() => policy.shouldRefreshAuthData(any(), any())).thenAnswer(
        (i) =>
            _authOf(i.positionalArguments[0] as RequestOptions) ==
            'Bearer ${i.positionalArguments[1]}',
      );
      final dio = buildDio(respondWith(401));

      await Future.wait([dio.get<dynamic>('/a'), dio.get<dynamic>('/b')]);

      verify(() => provider.requestAuthDataRefresh('old')).called(1);
      final retried = verify(() => retrier.retryRequest(captureAny())).captured;
      expect(retried.map((e) => _authOf(e as RequestOptions)), [
        'Bearer new',
        'Bearer new',
      ]);
    },
  );

  test('recoveryExceptionShouldNameTheReasonAndTheCause', () {
    expect(
      const AuthRecoveryException(AuthRecoveryFailure.refreshFailed).toString(),
      'AuthRecoveryException: refreshFailed',
    );
    expect(
      const AuthRecoveryException(
        AuthRecoveryFailure.retryFailed,
        cause: 'offline',
      ).toString(),
      'AuthRecoveryException: retryFailed, caused by: offline',
    );
  });
}
