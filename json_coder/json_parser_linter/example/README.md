# Example

A minimal project with the plugin enabled.

`pubspec.yaml`:

```yaml
dependencies:
  json_parser_annotations: ^1.0.1
```

`analysis_options.yaml`:

```yaml
plugins:
  json_parser_linter:
    version: ^1.0.5
    diagnostics:
      json_parser_requirements: true
```

`lib/user.dart`:

```dart
import 'package:json_parser_annotations/json_parser_annotations.dart';

// Meets the requirements: nothing is reported.
@GenerateJsonParser()
class User {
  final int id;
  final String name;

  User({required this.id, required this.name});

  factory User.fromJson(Map<String, dynamic> json) =>
      User(id: json['id'] as int, name: json['name'] as String);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

// Reported by json_parser_requirements: it has no toJson method.
@GenerateJsonParser()
class Address {
  final String city;

  Address({required this.city});

  factory Address.fromJson(Map<String, dynamic> json) =>
      Address(city: json['city'] as String);
}
```

Run `dart analyze` (or `flutter analyze`) and the plugin reports the missing
`toJson` on `Address`. See the package's [README](../README.md) for every
check the rule makes.
