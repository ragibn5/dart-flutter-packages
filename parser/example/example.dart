import 'package:parser/parser.dart';

// A basic custom type
class User {
  final int id;
  final String name;

  User(this.id, this.name);

  @override
  String toString() {
    return 'User{id: $id, name: $name}';
  }
}

// Create a custom parser for the User
class UserParser implements Parser<User, Map<String, dynamic>> {
  @override
  User decode(Map<String, dynamic> encoded) {
    return User(encoded['id'] as int, encoded['name'] as String);
  }

  @override
  Map<String, dynamic> encode(User value) {
    return {'id': value.id, 'name': value.name};
  }
}

// Create a parser registry
class MyParserRegistry extends ParserRegistry<Map<String, dynamic>> {
  MyParserRegistry() : super() {
    addParser(UserParser());
    // Add parsers for other types
    // ...
  }
}

void main() {
  final user = User(1, 'John');
  final userParser = UserParser();

  // Use of the parser
  final encoded = userParser.encode(user);
  final decoded = userParser.decode(encoded);
  // Output: {'id': 1, 'name': 'John'}
  print(encoded);
  // Output: User{id: 1, name: John}
  print(decoded);

  // Use of the parser registry
  final parserRegistry = MyParserRegistry();
  final userParserFromRegistry = parserRegistry.getParser<User>();
  final encodedFromRegistry = userParserFromRegistry!.encode(user);
  final decodedFromRegistry =
      userParserFromRegistry.decode(encodedFromRegistry);
  // Output: {'id': 1, 'name': 'John'}
  print(encodedFromRegistry);
  // Output: User{id: 1, name: John}
  print(decodedFromRegistry);
}
