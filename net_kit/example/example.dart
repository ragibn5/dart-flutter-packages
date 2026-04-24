import 'package:net_kit/net_kit.dart';

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

Future<void> main() async {
  final client = NetClientFactory.create(
    const DefaultClientConfig(
      baseUrl: 'https://example.com/api',
      connectionTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 5),
    ),
  );

  final request = RequestSpec<Object?>(
    pathOrUrl: '/users/1',
    method: HttpMethod.GET,
    body: null,
    sendTimeout: const Duration(seconds: 2),
    receiveTimeout: const Duration(seconds: 2),
  );

  final result = await client.execute(spec: request, codec: const UserCodec());

  result.fold(
    onSuccess: (response) {
      if (response.data.isSuccess) {
        final user = response.data.resultOrNull!;
        print('User: ${user.name}');
      } else {
        final apiError = response.data.errorOrNull!;
        print('Domain error: ${apiError.message}');
      }
    },
    onError: (error) {
      switch (error) {
        case NetworkException(type: final type):
          print('Network error: $type');
        case ParseException():
          print('Response parsing failed');
        case UnexpectedException(message: final message):
          print('Unexpected error: $message');
        case CancellationException():
          print('Request was cancelled');
      }
    },
  );
}
