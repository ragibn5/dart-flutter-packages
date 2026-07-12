# json_parser

A lightweight & flexible JSON parser for encoding and decoding data in Dart & Flutter applications.

## Features

- Built-in JSON parsing capability.
- Type-safe encoding and decoding.
- Type-safe parser registry for custom & built-in type parsers.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  json_parser: ^1.0.0
```

#### Or, From Git repo

```yaml
dependencies:
  json_parser:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: json_parser
      ref: main
```

### Usage

#### Primitive parsers

```dart
import 'package:json_parser/src/parsers/int_parser.dart';

void main() {
  const parser = IntParser();
  final encoded = parser.encode(42);
  final decoded = parser.decode(encoded);

  print(encoded); // 42
  print(decoded); // 42
}
```

Built-in parsers are also available for other primitive types such as `bool`, `double`, and
`String`.

#### Create a parser implementation using [`Parser`] from [

`parser`](../parser/lib/src/parser.dart) package:

Let a custom type be:

```dart
class User {
  final int id;
  final String name;

  User(this.id, this.name);

  @override
  String toString() {
    return 'User{id: $id, name: $name}';
  }
}
```

Build a parser for type `User`:

```dart
// Create a custom parser for the User
class UserParser implements Parser<User, Json> {
  const UserParser();

  @override
  User decode(Json encoded) {
    final map = encoded! as JsonMap;

    return User(
      id: map['id']! as int,
      name: map['name']! as String,
    );
  }

  @override
  Json encode(User value) {
    return {
      'id': value.id,
      'name': value.name,
    };
  }
}

// Usage
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
}
```

[`Json`, `JsonMap` & `JsonList`](lib/src/types/json_types.dart) are type-aliases that should be used
to construct all custom JSON parser implementations.

#### Building a parser registry using [

`JsonParserRegistry`](lib/src/registry/json_parser_registry.dart):

```dart
// Usage
void main() {
  final user = User(1, 'John');
  final userParser = UserParser();

  // Use of the json parser registry
  // Create a registry with known parsers (or use default constructor for empty registry)
  final jsonParserRegistry = JsonParserRegistry.withKnownParsers();
  jsonParserRegistry.addParser(userParser);

  final userParserFromRegistry = jsonParserRegistry.getParser<User>();
  final encodedFromRegistry = userParserFromRegistry!.encode(user);
  final decodedFromRegistry = userParserFromRegistry.decode(encodedFromRegistry);
  // Output: {'id': 1, 'name': 'John'}
  print(encodedFromRegistry);
  // Output: User{id: 1, name: John}
  print(decodedFromRegistry);
}
```

<br><br>
See the example section for more examples, like encoding/decoding primitive constructs and more.

### Tooling

Additional tooling is available for `json_parser`:

- [`json_parser_generator`](json_parser_generator/README.md): Generates type-safe JSON parsers and
  parser registries for annotated models.
- [`json_parser_analyzer`](json_parser_analyzer/README.md): Adds analyzer checks to enforce
  `json_parser`-compatible model structures.

### Example

See the [example](example/example.dart) for a complete demonstration.
