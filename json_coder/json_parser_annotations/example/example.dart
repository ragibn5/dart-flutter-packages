import 'package:json_parser_annotations/json_parser_annotations.dart';

@GenerateJsonParser()
class User {
  final int id;
  final String name;

  User(this.id, this.name);

  @override
  String toString() {
    return 'User{id: $id, name: $name}';
  }
}
