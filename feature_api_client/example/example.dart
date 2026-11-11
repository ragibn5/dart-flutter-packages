import 'package:dio/dio.dart';
import 'package:feature_api_client/feature_api_client.dart';
import 'package:net_models/net_models.dart';

class GetUserRequest {
  final String id;

  GetUserRequest(this.id);
}

class User {
  final String name;

  User(this.name);
}

class ServerMessage {
  final String message;

  ServerMessage(this.message);
}

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
        error: ServerMessage(json['message'] as String),
        statusCode: statusCode,
        headers: response.headers.map,
      );
    }
    return SuccessResponse(
      data: User(json['name'] as String),
      statusCode: statusCode,
      headers: response.headers.map,
    );
  }
}

Future<void> main() async {
  final client = UserClient(Dio(BaseOptions(baseUrl: 'https://example.com')));

  final result = await client.request(GetUserRequest('42'));
  result.fold(
    onLeft: (error) => print('No answer: $error'),
    onRight: (response) => response.fold(
      onFailure: (message) => print('Server error: ${message.message}'),
      onSuccess: (user) => print('User: ${user.name}'),
    ),
  );
}
