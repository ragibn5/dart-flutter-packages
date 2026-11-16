# feature_api_client

A feature-based, type-safe API client over [`dio`](https://pub.dev/packages/dio).

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  dio: ^5.8.0+1
  dart_functionals: ^1.0.1
  net_models: ^1.0.0
  feature_api_client: ^2.0.0
```

#### Or, From Git repo

```yaml
dependencies:
  feature_api_client:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: feature_api_client
      ref: feature_api_client-2.0.0
```

## Get started

Define a client per API feature, with typed request, response and error
contracts. The client sends the request through `dio`, decodes what the server
answers, and maps the failures with no answer to a `net_models` `ApiError`.

### Define a feature client

Extend `FeatureApiClient<Req, Res, Err>` and implement:

- `send`: Send the request through the given `Dio`, with any of its options
  (query parameters, multipart, progress, cancel tokens).
- `decodeResponse`: Decode what the server answered, whatever its status: the
  `Res` on success, the `Err` otherwise.

```dart
class UserClient extends FeatureApiClient<GetUserRequest, User, ServerMessage> {
  UserClient(super.dio);

  @override
  Future<Response<Object?>> send(Dio dio, GetUserRequest body) =>
      dio.get<Object?>('/users/${body.id}');

  @override
  ApiResponse<ServerMessage, User> decodeResponse(Response<Object?> response) {
    final json = response.data! as Map<String, dynamic>;
    final statusCode = response.statusCode!;
    if (statusCode >= 400) {
      return FailureResponse(
        error: ServerMessage.fromJson(json),
        statusCode: statusCode,
        headers: response.headers.map,
      );
    }
    return SuccessResponse(
      data: User.fromJson(json),
      statusCode: statusCode,
      headers: response.headers.map,
    );
  }
}
```

### Make the call

```dart
final client = UserClient(dio);

final result = await client.request(GetUserRequest('42'));
result.fold(
  onLeft: (error) => print('No answer: $error'),
  onRight: (response) => response.fold(
    onFailure: (message) => print('Server error: $message'),
    onSuccess: (user) => print('User: $user'),
  ),
);
```

`request` never throws:

- **No answer** (a timeout, no connection, a cancellation): the `ApiError`
  from `DioExceptionTransformer`.
- **An answer, whatever its status:** what `decodeResponse` made of it.
- **An answer `decodeResponse` couldn't decode:** an `UnexpectedError`.

## Example

See the [example](example/example.dart) for a complete demonstration.
