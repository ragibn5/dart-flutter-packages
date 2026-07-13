# parser

A foundational package for creating new parser libraries.

## Overview

`parser` is a foundational library that streamlines the process of creating new parser libraries.

## Features

- Type-safe encoding and decoding.
- Type-safe parser registry for custom & built-in type parsers.
- Extensible architecture for building parsers for custom & built-in types.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  parser: ^1.0.0
```

#### Or, From Git repo

```yaml
dependencies:
  parser:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: parser
      ref: main
```

### Usage

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

Create a parser implementation using [`Parser`](lib/src/parser.dart):

```dart
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

Creating a parser registry using [`ParserRegistry`](lib/src/parser_registry.dart):

```dart
// Create a parser registry
class MyParserRegistry extends ParserRegistry<Map<String, dynamic>> {
  MyParserRegistry() : super() {
    addParser(UserParser());
    // Add parsers for other types
    // ...
  }
}

// Usage
void main() {
  final user = User(1, 'John');
  final userParser = UserParser();

  // Use of the parser registry
  final parserRegistry = MyParserRegistry();
  final userParserFromRegistry = parserRegistry.getParser<User>();
  final encodedFromRegistry = userParserFromRegistry!.encode(user);
  final decodedFromRegistry = userParserFromRegistry.decode(encodedFromRegistry);
  // Output: {'id': 1, 'name': 'John'}
  print(encodedFromRegistry);
  // Output: User{id: 1, name: John}
  print(decodedFromRegistry);
}
```

### Example

See the [example](example/example.dart) for a complete demonstration.
