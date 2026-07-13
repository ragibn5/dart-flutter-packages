# json_parser_generator

Generator counterpart of the [`json_parser`](../../json_parser) package.

## Overview

`json_parser_generator` is the code generation counterpart of the [`json_parser`](../../json_parser)
package. It automates the creation of type-safe JSON parsers and generates parser registries that
register those parsers.

## Features

- Generates type-safe JSON parsers for annotated classes.
- Generates parser registries for centralized parser management.
- Eliminates manual parser wiring and reduces boilerplate.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  json_parser_annotations: ^1.0.0

dev_dependencies:
  build_runner: ^2.4.15
  json_parser_generator: ^1.0.0
```

#### Or, From Git repo

```yaml
dependencies:
  json_parser_annotations:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: json_parser/json_parser_annotations
      ref: 1.0.0

dev_dependencies:
  build_runner: ^2.4.15
  json_parser_generator:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: json_parser/json_parser_generator
      ref: 1.0.0
```

## Get started

**1. Configure options in `build.yaml` (Optional):**

You can add optional configuration options to your `build.yaml` file.

The only configuration you have at the moment is a log configuration.
It is useful while setting up or debugging generation.

- `enabled`: Turns logging on for the builder.
- `log_dir_relative_path`: Sets where logs are stored relative to the package root.
- `allow_info`, `allow_warning`, `allow_error`: Controls which log levels are written.

```yaml
targets:
  $default:
    builders:
      json_parser_generator|json_parsers_builder:
        options:
          log_config:
            enabled: true
            allow_info: true
            allow_warning: true
            allow_error: true
            log_dir_relative_path: logs/generators/json_parser_generator
```

**2. Annotate your model with `@GenerateJsonParser()`.**

The annotation is available through `json_parser_annotations` package.

```dart
import 'package:json_parser_annotations/json_parser_annotations.dart';

@GenerateJsonParser()
class User {
  const User({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']! as int,
      name: json['name']! as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
```

**3. Run the builder:**

```sh
dart run build_runner build --delete-conflicting-outputs
```

This generates `lib/generated/json_parser/parsers.dart`, which contains the generated parser and
registry classes for your annotated models.
