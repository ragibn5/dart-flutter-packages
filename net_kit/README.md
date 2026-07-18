# net_kit

An opinionated wrapper around [`dio`](https://pub.dev/packages/dio) that streamlines
request/response transformation and error handling.

## Installation

This package is not published to pub.dev yet. Use the git dependency:

```yaml
dependencies:
  dart_functionals:
  git:
    url: https://github.com/Ragibn5/dart-flutter-packages.git
    path: dart_functionals
    ref: main
  net_kit:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: net_kit
      ref: main
```

> **Note:** `dart_functionals` is required.

## Get started

### 1. Create the client

```dart
final client = NetClientFactory.create(
  const ClientConfig(
    baseUrl: 'https://your-api.example.com',
    connectionTimeout: Duration(seconds: 5),
    receiveTimeout: Duration(seconds: 5),
  ),
);
```

### 2. Build a `RequestSpec`

`RequestSpec` describes a request, for example:

```dart
final request = RequestSpec(
  pathOrUrl: '/users',
  method: HttpMethod.POST,
  body: const JsonBody({'name': 'Ragib'}),
  queryParameters: const {'include': 'profile'},
  headers: const {'x-request-id': 'abc-123'},
  sendTimeout: const Duration(seconds: 3),
  receiveTimeout: const Duration(seconds: 3),
);
```

#### Note

The content type is automatically inferred for the following body types and can also be provided
explicitly if you want to override the default ones.

- `JsonBody` → `application/json`
- `FormUrlEncodedBody` → `application/x-www-form-urlencoded`
- `MultipartBody` → `multipart/form-data`

But for `RawBody`, the content type **must be provided explicitly**, as raw data may represent different
types of data.

### 3. Execute and handle the request

`execute(...)` returns:

- `Failure(NetKitException)` contains infrastructure failures.
  See `NetKitException` and its subtypes for more details.
- `Success(ApiResponse(...))` contains the response data.
  See the `ApiResponse` type for more details.

For example:

```dart
void main() async {
  // Execute
  final result = await client.execute(spec: request);

  // Handle response as needed
  result.fold(
    onFailure: (error) {
      switch (error) {
        case TransportException(type: final type):
          print('Transport/Network error: $type');
        case UnexpectedException(message: final message):
          print('Unexpected error: $message');
        case CancellationException():
          print('Cancelled');
      }
    },
    onSuccess: (response) {
      print('Success: ${response.data}');
    },
  );
}
```

## Complete Example

See the [example](example/example.dart) for a complete demonstration.
