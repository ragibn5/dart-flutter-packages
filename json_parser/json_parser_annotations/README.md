# json_parser_annotations

Annotations to support analysis and code-gen features for [`json_parser`](../../json_parser) package.

## Overview

Defines annotations to support analysis and code-gen features for [`json_parser`](../../json_parser) package.

## Installation

#### From pub.dev (Not yet available, use git based dependency management for now)

Add this to your `pubspec.yaml`

```yaml
dependencies:
  json_parser_annotations: ^0.0.1
```

#### Or, From Git repo (Internal members only)

```yaml
dependencies:
  json_parser_annotations:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: json_parser_annotations
      ref: main
```

### Usage

Annotate any types with the supplied annotations, for example:

```dart
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
```

### Example

See the [example](example/example.dart) for a complete demonstration.

## License

Click [here](../../LICENSE) to see the license.