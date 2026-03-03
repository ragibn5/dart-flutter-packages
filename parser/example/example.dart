// ignore_for_file: cascade_invocations

import 'package:parser/parser.dart';

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

void main() {
  final user = User(age: 30, name: 'Ragib');

  jsonParserUsage(user);
}

// JSON parser example
void jsonParserUsage(User user) {
  final jsonParser = JsonParser();

  // Add decoders.
  // This is required to decode an encoded instance.
  // This must be done prior to decoding this type (User).
  jsonParser.addDecoder(User.fromJson);

  // The encoded form of user
  final encodedUser = jsonParser.encode(user);
  print(encodedUser);

  // The decoded form of the encoded user.
  // Will contain same values as the original `User` instance.
  final decodedUser = jsonParser.decode<User>(encodedUser);
  print(jsonParser.encode(decodedUser));
}
