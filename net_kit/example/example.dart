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
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://example.com/api',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  // Ignore this block
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(
          Response<dynamic>(
            requestOptions: options,
            statusCode: 200,
            data: const {
              'id': 1,
              'name': 'Ragib',
            },
          ),
        );
      },
    ),
  );

  final client = DioNetClient(dio);

  final request = RequestSpec<Object?>(
    path: '/users/1',
    method: HttpMethod.GET,
    body: null,
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
