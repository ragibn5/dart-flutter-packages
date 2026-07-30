# json_parser_generator

Generator counterpart of the [`json_parser`](../.) package.

> **Note:** This package is a part of the [`json_parser`](../.) suite.

- Generates type-safe JSON parsers for annotated classes.
- Generates parser registries for centralized parser management.
- Eliminates manual parser wiring and reduces boilerplate.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  json_parser_annotations: ^1.0.1

dev_dependencies:
  build_runner: ^2.4.15
  json_parser_generator: ^1.0.1
```

#### Or, From Git repo

```yaml
dependencies:
  json_parser_annotations:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: json_parser/json_parser_annotations
      ref: json_parser/json_parser_annotations-1.0.1

dev_dependencies:
  build_runner: ^2.4.15
  json_parser_generator:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: json_parser/json_parser_generator
      ref: json_parser/json_parser_generator-1.0.1
```

## ✨ Features

- Generates type-safe JSON parser registries for `@GenernateJsonParser` annotated classes.
- Supports registering a model into multiple registries at the same time.
- Eliminates manual parser wiring and reduces boilerplate.

## 🚀 Get started

**1️⃣ (Optional) Configure the builder in `build.yaml`**

By default, the builder works without any configuration. If you need debugging or logging, create a `build.yaml`.

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

| Option                  | Description                                | Default                                 |
|-------------------------|--------------------------------------------|-----------------------------------------|
| `enabled`               | Enables logging for the builder            | `false`                                 |
| `allow_info`            | Logs informational messages                | `false`                                 |
| `allow_warning`         | Logs warning messages                      | `true`                                  |
| `allow_error`           | Logs error messages                        | `true`                                  |
| `log_dir_relative_path` | Log directory relative to the package root | `logs/generators/json_parser_generator` |

> For the full `build.yaml` schema reference, see the [build_config](https://pub.dev/packages/build_config) package documentation.

**2️⃣ Annotate your model with `@GenerateJsonParser()`**

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

> **Note:** The annotation is available through `json_parser_annotations` package.

**3️⃣ Run the builder**

```sh
dart run build_runner build --delete-conflicting-outputs
```

🎯 This generates `lib/generated/json_parser/parsers.dart`, which contains the generated parser and registry classes for your annotated models.
