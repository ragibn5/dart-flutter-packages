import 'package:parser_annotations/parser_annotations.dart';

@JsonCodable()
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
