# json_parser_annotations

Annotations to support analysis and code-gen features for [`json_coder`](../.) package.

> Note: This package is a part of the [`json_coder`](../.) suite.

## Overview

Defines annotations to support analysis and code-gen features for [`json_coder`](../.) package.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  json_parser_annotations: ^1.0.1
```

#### Or, From Git repo

```yaml
dependencies:
  json_parser_annotations:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: json_coder/json_parser_annotations
      ref: json_coder/json_parser_annotations-1.0.1
```

## Usage

Annotate the components you want to expose:

```dart
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
```

Once annotated, generators, analyzers and other tools can find these components and apply their integrations.

### Example

See the [example](example/example.dart) for a complete demonstration of all the annotations.
