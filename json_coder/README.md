# json_coder

A lightweight and flexible JSON parser for encoding and decoding data in Dart & Flutter applications.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  json_coder: ^1.0.0
```

#### Or, From Git repo

```yaml
dependencies:
  json_coder:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: json_coder
      ref: json_coder-1.0.0
```

## ✨ Features

A small, composable toolkit for turning Dart objects into JSON and back:

- Built-in parsers for all primitive types.
- Composable parsers for any nested structures.
- Support for custom parser implementation.
- Type-safe registry for looking up parsers by type.
- Pinpoint debugging — know the exact location where parsing failed.
- Available companion tools:
    - [`json_parser_generator`](json_parser_generator): Generates type-safe JSON parser [registries](#-building-a-parser-registry) for annotated models.
    - [`json_parser_linter`](json_parser_linter): Adds analyzer checks to enforce `json_coder`-compatible model structures.

### 🚀 Get Started

#### 🧩 Built-in parsers

Available built-in parsers:

| Parser                    | Decodes to   | Notes                                          |
|---------------------------|--------------|------------------------------------------------|
| `BoolParser`              | `bool`       |                                                |
| `IntParser`               | `int`        | Accepts `double`, truncates                    |
| `DoubleParser`            | `double`     | Accepts `int`                                  |
| `NumParser`               | `num`        | Accepts `int` / `double`                       |
| `StringParser`            | `String`     |                                                |
| `NullableBoolParser`      | `bool?`      | Passes `null` through                          |
| `NullableIntParser`       | `int?`       | Passes `null` through                          |
| `NullableDoubleParser`    | `double?`    | Passes `null` through                          |
| `NullableNumParser`       | `num?`       | Passes `null` through                          |
| `NullableStringParser`    | `String?`    | Passes `null` through                          |
| `ListParser<T>`           | `List<T>`    | Decodes each element with an item parser       |
| `MapParser<K, V>`         | `Map<K, V>`  | Decodes keys and values with key/value parsers |
| `NullableListParser<T>`   | `List<T>?`   | Passes `null` through                          |
| `NullableMapParser<K, V>` | `Map<K, V>?` | Passes `null` through                          |

For example:

```dart
import 'package:json_coder/src/parsers/int_parser.dart';

void main() {
  const parser = IntParser();
  final encoded = parser.encode(42);
  final decoded = parser.decode(encoded);

  // For primitives, the encoded value is the value itself
  print(encoded); // 42
  print(decoded); // 42
}
```

#### 🔗 Composing parsers for complex types

If you are feeling lazy or do not want to create a custom type, you can compose the built-in parsers to build a parser for any valid JSON structures.

For example, here is a composed parser for a `Map<String, List<num>>`:

```dart

final parser = MapParser(
  keyParser: const StringParser(),
  valueParser: ListParser(const NumParser()),
);

final encoded = {
  'scores': [10, 20.5, 30],
};

final decoded = parser.decode(encoded);
```

Or even deeper:

```dart

final parser = ListParser(
  MapParser(
    keyParser: const StringParser(),
    valueParser: ListParser(const NumParser()),
  ),
);
```

> **Note:**
> There are no limits on how deep or complex you can compose.
> But it is generally recommended to create a custom type and its corresponding parser implementation instead (if it gets too complex).

#### ✏️ Create a custom parser

For custom types, create custom parser implementations using `Parser`.

Let's model a `User`:

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

Now build a parser for it:

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

Custom parser implementations work with these JSON type aliases:

| Type alias | Represents     | Underlying type     |
|------------|----------------|---------------------|
| `Json`     | Any JSON value | `Object?`           |
| `JsonList` | JSON array     | `List<Json>`        |
| `JsonMap`  | JSON object    | `Map<String, Json>` |

#### 📦 Building a parser registry

A parser registry keeps parsers in one place, registered by type so you can look them up later.

For example,

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

#### ⚠️ Handling decode errors

Parsers throw a `JsonParseException` when decoding fails.

```
try {
  final decoded = parser.decode(encoded);
} on JsonParseException catch (e) {
  print(e.message); // Expected number, but got String
  print(e.path); // ['users', 1, 'age']
  print(e); // Expected number, but got String at $['users'][1]['age']
}
```

Composite parsers (list and map) record the failing list index or map key in `e.path`, so errors in nested structures pinpoint the exact failing value.

### 🛠️ Tooling

- [`json_parser_generator`](json_parser_generator): Generates type-safe JSON parser [registries](#-building-a-parser-registry) for annotated models.
- [`json_parser_linter`](json_parser_linter): Adds analyzer checks to enforce `json_coder`-compatible model structures.

### 🎯 Example

See the example for a complete demonstration.