// ignore_for_file: prefer_final_locals
// ignore_for_file: omit_local_variable_types
//
// Please use your app specific implementation.
// The components here are minimal and for demonstration purpose only.

import 'package:net_kit/net_kit.dart';
import 'package:parser/parser.dart';

// Model class
class User {
  final int age;
  final String name;

  User({
    required this.age,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'name': name,
    };
  }

  factory User.fromJson(Map<String, dynamic> map) {
    return User(
      age: map['age'] as int,
      name: map['name'] as String,
    );
  }
}

// Base error class
sealed class ApiError {}

// Error variants
final class LocalError extends ApiError {
  final String message;

  LocalError({required this.message});
}

final class ServerError extends ApiError {
  final int statusCode;
  final String errorMessage;

  ServerError({
    required this.statusCode,
    required this.errorMessage,
  });
}

// Error mapper implementation
class ApiErrorMapper extends ErrorMapper<ApiError> {
  @override
  ApiError mapError(Object exception, StackTrace? stackTrace) {
    if (exception is DioException) {
      final response = exception.response;
      if (response != null) {
        return ServerError(
          statusCode: response.statusCode ?? 0,
          errorMessage: response.data?.toString() ?? 'Unknown error',
        );
      } else {
        return LocalError(message: 'Network error: ${exception.type}');
      }
    } else {
      return LocalError(message: exception.toString());
    }
  }
}

// Parser implementation
class MyJsonParser extends JsonParser {
  MyJsonParser() {
    addDecoder(User.fromJson);
    // ...
    // Other decoder registration here ...
  }
}

void main() async {
  /// ### Create parser instance.
  /// You may also use `JsonParser` inline.
  /// But you will need to register the decoders inline as well, for example:
  /// ```
  /// final dataParser = JsonParser();
  /// dataParser.addDecoder(User.fromJson);
  /// Other decoder registration here ...
  /// ```
  ///
  /// It is recommended to create a class that extends a parser,
  /// like `JsonParser`, and use that instead.
  /// Even better, use the parser implementation generator library. See
  /// the readme for more info.
  final jsonParser = MyJsonParser();

  // Create error mapper instance
  final errorMapper = ApiErrorMapper();

  // Create the client
  final client = NetKit(
    client: Dio(
      BaseOptions(
        baseUrl: 'https://example.api.com',
        connectTimeout: const Duration(seconds: 5),
      ),
    ),
    dataParser: jsonParser,
    errorMapper: errorMapper,
  );

  // Example api calls
  Result<ApiError, User> response = await client.get<User>('/user');
  // Or, shorthand
  // final response = await client.get<User>('/user');

  // Handle the error
  response.fold(
    onSuccess: (data) {
      // Handle the result inline or return something
      // `data` is of type `User` (Strongly typed result)
      return data.toString();
    },
    onError: (error) {
      // Handle the error inline or return something
      // `error` is of type `ApiError` (Strongly typed error)
      return error.toString();
    },
  );
}
