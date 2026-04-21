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

`RequestCodec<Req, Res, Err>` tells the client how to:

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
import 'package:dio/dio.dart';
import 'package:net_kit/dio_net_client.dart';

final dio = Dio(
  BaseOptions(
    baseUrl: 'https://your-api.example.com',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ),
);
```

Configure interceptors, headers, auth, retries, or logging on `dio` exactly as you normally would.

### 4. Create the Client

```dart

final client = DioNetClient(dio);
```

### 5. Build a `RequestSpec`

`RequestSpec<Req>` describes a request, for example:

```dart

final request = RequestSpec<Map<String, dynamic>>(
  path: '/users',
  method: HttpMethod.POST,
  body: const {'name': 'Ragib'},
  queryParameters: const {'include': 'profile'},
  headers: const {'x-request-id': 'abc-123'},
);
```

### 6. Execute and handle the request

`execute(...)` returns:

- `Result.error(...)` contains infrastructure failures as `NetClientException`.
  See `NetClientException` and its subtypes for more details.
- `Result.success(ApiResponse(...))` contains either a decoded success payload
  or a decoded domain error payload. See the `ApiResponse` type for more details.

For example:

```dart
void main() async {
  // Execute
  final result = await client.execute(spec: request, codec: const UserCodec());

  // Handle response as needed
  result.fold(
    onSuccess: (response) {
      if (response.data.isSuccess) {
        final user = response.data.resultOrNull!;
        print(user.name);
      } else {
        final apiError = response.data.errorOrNull!;
        print('API error: ${apiError.message}');
      }
    },
    onError: (error) {
      switch (error) {
        case NetworkException(type: final type):
          print('Network error: $type');
        case ParseException():
          print('Parsing failed');
        case UnexpectedException(message: final message):
          print('Unexpected error: $message');
        case CancellationException():
          print('Cancelled');
      }
    },
  );
}
```

## Complete Example

See the [example](example/example.dart) for a complete demonstration.

## License

Click [here](../LICENSE) to see the license.
