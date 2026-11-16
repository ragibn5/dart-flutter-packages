# base_auth_interceptor

A reusable auth interceptor base for [`dio`](https://pub.dev/packages/dio).

It authorizes every request, and on an auth error refreshes the auth data and
retries the request. Requests pass through one at a time, so concurrent auth
errors lead to a single refresh.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  base_auth_interceptor: ^2.0.0
```

#### Or, From Git repo

```yaml
dependencies:
  base_auth_interceptor:
    git:
      url: https://github.com/ragibn5/dart-flutter-packages.git
      path: base_auth_interceptor
      ref: base_auth_interceptor-2.0.0
```

## 🚀 Get started

### AuthDataProvider

Supplies current and refreshed auth data.

```dart
class AuthDataProviderImpl implements AuthDataProvider<String> {
  @override
  Future<String?> getAuthData() async => 'my-token';

  @override
  Future<String?> requestAuthDataRefresh(String oldAuthData) async =>
      'my-new-token';
}
```

### AuthRefreshPolicy

Decides when an auth error should trigger a refresh.

```dart
class AuthRefreshPolicyImpl implements AuthRefreshPolicy<String> {
  @override
  bool didServerReportAuthError(Response<dynamic> response) =>
      response.statusCode == HttpStatus.unauthorized;

  /// Refresh only if the request was sent with the current auth data;
  /// otherwise another request has refreshed it already.
  @override
  bool shouldRefreshAuthData(RequestOptions request, String authData) =>
      request.headers[HttpHeaders.authorizationHeader] == 'Bearer $authData';
}
```

### AuthRequestTransformer

Adds auth data to requests, and to the retried request after a refresh.

```dart
class AuthRequestTransformerImpl implements AuthRequestTransformer<String> {
  @override
  Future<RequestOptions> transformRequestWithAuthData(
    RequestOptions request,
    String authData,
  ) async =>
      request.copyWith(
        headers: {
          ...request.headers,
          HttpHeaders.authorizationHeader: 'Bearer $authData',
        },
      );
}
```

### Compose

`retryDio` sends a request again after an auth error, with the auth data
already applied. Use a `Dio` without the interceptor: a request sent through
the interceptor's own `Dio` waits behind its queue, which is waiting for the
retry.

```dart
final options = BaseOptions(baseUrl: 'https://example.com');
final dio = Dio(options)
  ..interceptors.add(
    AuthInterceptor<String>(
      AuthDataProviderImpl(),
      AuthRefreshPolicyImpl(),
      AuthRequestTransformerImpl(),
      retryDio: Dio(options),
    ),
  );
```

### When recovery fails

The request is rejected with a cancelled `DioException` whose `error` is an
`AuthRecoveryException`. Its `reason` says why: no auth data, the refresh
failed, or the retry failed (with the retry's error as its `cause`).

## 🧪 Example

See the [example](example/example.dart) for a complete demonstration.
