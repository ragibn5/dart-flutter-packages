# parser_annotations

Defines the annotations specific to [parser](../parser) package.

To use analysis and code generation tools specific to `parser`,
we need to use annotations from this package in the host application.
Of course, the specific tools also uses specific annotations from this package too.

For example, currently, the following packages use [JsonCodable](lib/src/json_codable.dart):

- [parser_analyzer](../parser_analyzer)
- [parser_generator](../parser_generator)

## Installation

#### From pub.dev (Not yet available, use git based dependency management for now)

Add this to your `pubspec.yaml`

```yaml
dependencies:
  parser_annotations: ^0.0.1
```

#### Or, From Git repo (Internal members only)

```yaml
dependencies:
  parser_annotations:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: parser_annotations
      ref: main
```

## Example

See the [example](example/example.dart) for a complete demonstration.

## License

Click [here](../LICENSE) to see the license.