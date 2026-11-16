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
  late _FakeAdapter retryAdapter;

  setUpAll(() {
    registerFallbackValue(RequestOptions());
    registerFallbackValue(Response<dynamic>(requestOptions: RequestOptions()));
  });

  setUp(() {
    provider = _MockAuthDataProvider();
    policy = _MockAuthRefreshPolicy();
    transformer = _MockAuthRequestTransformer();
    retryAdapter = _FakeAdapter((_) => ResponseBody.fromString('retried', 200));

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
        AuthInterceptor(
          provider,
          policy,
          transformer,
          retryDio: Dio()..httpClientAdapter = retryAdapter,
        ),
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
    expect(retryAdapter.requests, isEmpty);
  });

  test('errorShouldPassThroughIfItIsNotAnAuthError', () async {
    final error = await requestError(buildDio(respondWith(500)));

    expect(error.type, DioExceptionType.badResponse);
    expect(error.response?.statusCode, 500);
    expect(retryAdapter.requests, isEmpty);
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
    expect(retryAdapter.requests, isEmpty);
  });

  test('authErrorShouldRefreshAndRetryIfTheAuthDataIsStale', () async {
    when(
      () => provider.requestAuthDataRefresh('old'),
    ).thenAnswer((_) async => 'new');

    final response = await buildDio(respondWith(401)).get<dynamic>('/a');

    expect(response.data, 'retried');
    expect(_authOf(retryAdapter.requests.single), 'Bearer new');
  });

  test('authErrorShouldRetryWithoutRefreshingIfTheAuthDataIsCurrent', () async {
    when(() => policy.shouldRefreshAuthData(any(), any())).thenReturn(false);

    final response = await buildDio(respondWith(401)).get<dynamic>('/a');

    expect(response.data, 'retried');
    verifyNever(() => provider.requestAuthDataRefresh(any()));
    expect(_authOf(retryAdapter.requests.single), 'Bearer old');
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
      expect(retryAdapter.requests, isEmpty);
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
    expect(retryAdapter.requests, isEmpty);
  });

  test('authErrorShouldBeCancelledAsRetryFailedIfTheRetryFails', () async {
    when(
      () => provider.requestAuthDataRefresh('old'),
    ).thenAnswer((_) async => 'new');
    retryAdapter = _FakeAdapter((_) => ResponseBody.fromString('', 500));

    final error = await requestError(buildDio(respondWith(401)));

    expect(error.type, DioExceptionType.cancel);
    final exception = error.error! as AuthRecoveryException;
    expect(exception.reason, AuthRecoveryFailure.retryFailed);
    expect(
      (exception.cause! as DioException).response?.statusCode,
      500,
    );
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
      expect(retryAdapter.requests.map(_authOf), [
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
