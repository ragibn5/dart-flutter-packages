# net_kit

An opinionated wrapper around [`dio`](https://pub.dev/packages/dio) that streamlines
request/response transformation and error handling.

## Installation

This package is not published to pub.dev yet. Use the git dependency:

```yaml
dependencies:
  net_kit:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: net_kit
      ref: main
```

## Get started

### 1. Create your response and error models

```dart
class User {
  final int id;
  final String name;

  const User({
    required this.id,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class ApiError {
  final String message;

  const ApiError(this.message);

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(json['message'] as String? ?? 'Unknown error');
  }
}
```

If you already have these, you may skip this step.

### 2. Implement a `RequestCodec`

`RequestCodec<Req, Res, Err>` tells `NetKit` how to:

- Encode the request body
- Decode the success body into `Res`
- Decode the error body into `Err`

```dart
class UserCodec implements RequestCodec<Object?, User, ApiError> {
  const UserCodec();

  @override
  Object? encodeBody(Object? body) => body;

  @override
  User decodeResponse(dynamic raw) {
    return User.fromJson(raw as Map<String, dynamic>);
  }

  @override
  ApiError decodeError(dynamic raw) {
    return ApiError.fromJson(raw as Map<String, dynamic>);
  }
}
```

### 3. Create and configure `Dio`

```dart

final dio = Dio(
  BaseOptions(
    baseUrl: 'https://your-api.example.com',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ),
);
```

Configure interceptors, headers, auth, retries, or logging on `dio` exactly as you normally would.

### 4. Create `NetKit`

```dart

final netKit = NetKit(dio);
```

### 5. Build a `RequestSpec`

`RequestSpec<Req, Res, Err>` describes one request:

```dart

final request = RequestSpec<Object?, User, ApiError>(
  path: '/users/1',
  method: HttpMethod.GET,
  body: null,
  codec: const UserCodec(),
);
```

Example with query parameters and headers:

```dart

final request = RequestSpec<Map<String, dynamic>, User, ApiError>(
  path: '/users',
  method: HttpMethod.POST,
  body: const {'name': 'Ragib'},
  codec: const UserCodec(),
  queryParameters: const {'include': 'profile'},
  headers: const {'x-request-id': 'abc-123'},
);
```

### 6. Execute the request

```dart
void main() async {
  final result = await netKit.execute(request, null, null, null);
}
```

Arguments after `request` are:

- `CancelToken? cancelToken`
- `ProgressCallback? onSendProgress`
- `ProgressCallback? onReceiveProgress`

Example with a cancel token:

```dart
void main() async {
  final cancelToken = CancelToken();
  final result = await netKit.execute(request, cancelToken, null, null);
}
```

### 7. Handle the result

On success, you get your decoded `Res`.
On failure, you get a `NetKitException`.

```dart
void main() async {
  result.fold(
    onSuccess: (user) {
      print(user.name);
    },
    onError: (error) {
      switch (error) {
        case DomainException<ApiError>(error: final apiError):
          print('API error: ${apiError.message}');
        case DomainException():
          print('API error');
        case NetworkException(type: final type):
          print('Network error: $type');
        case ParseException():
          print('Parsing failed');
        case UnexpectedException(message: final message):
          print('Unexpected error: $message');
        case CancellationException():
          print('Cancelled');
        case ApplicationException():
          print('Application error');
      }
    },
  );
}
```

## Error Model

`NetKit.execute(...)` returns:

```dart
Result<NetKitException, Res>
```

Possible error types:

- `DomainException<Err>`
  The server responded with an error body, and `decodeError(...)` succeeded.
- `NetworkException`
  Dio reported a transport-level failure such as timeout, certificate issue, or
  connection failure.
- `ParseException`
  Encoding or decoding failed.
- `CancellationException`
  The request was cancelled.
- `UnexpectedException`
  An uncategorized failure occurred.

## Custom Error Classification

By default, responses with `statusCode >= 400` are treated as errors.

If your backend uses something else, provide a custom `ResponseClassifier` in
the request spec.

Example: an API that always returns `200` and uses `success: false` in the
response body.

```dart
class ApiResponseClassifier implements ResponseClassifier {
  const ApiResponseClassifier();

  @override
  bool isError(Response<dynamic> response) {
    final body = response.data as Map<String, dynamic>?;
    return body?['success'] != true;
  }
}

final request = RequestSpec<Object?, User, ApiError>(
  path: '/users/1',
  method: HttpMethod.GET,
  body: null,
  codec: const UserCodec(),
  responseClassifier: const ApiResponseClassifier(),
);
```

## Raw Methods

Use these when you want direct `dio` behavior without codec-based decoding:

- `executeRaw`
- `executeRawWithOptions`
- `download`
- `downloadUri`
- `close`

Example:

```dart
void main() async {
  final response = await
  netKit.executeRaw(
    '/files/report.pdf'
    , options: Options(method: 'GET'),
  );
}
```

## Complete Example

See the [example](example/example.dart) for a complete demonstration.

## License

Click [here](../LICENSE) to see the license.
