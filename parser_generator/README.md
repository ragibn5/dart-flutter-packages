# parser_generator

Collection of code generators for public components of [parser](../parser).

## Overview

Collection of code generators specific to the public components of [parser](../parser)
package. Auto generate prefilled parser implementations and much more.

## Installation

#### From pub.dev (Not yet available, use git based dependency management for now)

Add this to your `pubspec.yaml`

```yaml
# Optional
dependencies:
  parser_annotations: ^0.0.1

# Required
dev_dependencies:
  build_runner: ^2.4.15
  parser_generator: ^0.0.1
```

#### Or, From Git repo (Internal members only)

```yaml
# Optional
dependencies:
  parser_annotations:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: parser_annotations
      ref: main

# Required
dev_dependencies:
  build_runner: ^2.4.15
  parser_generator:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: parser_generator
      ref: main
```

## Configuration

Create a `parser_config.yaml` file in your project root.

The configuration for [`JsonParser`](../parser/lib/src/parser_impls/json_parser.dart)
based parsers must contain either `default_parser` or `keyed_parsers`.

- The `default_parser` config defines the parser to generate in case the `parserKey` field is not
  specified while annotating the models with
  [`JsonCodable`](../parser_annotations/lib/src/json_codable.dart).
- If `parserKey` is specified, and a matching config is found under `json_parser.keyed_parsers`,
  that is used.

```yaml
json_parser:
  # Default config
  default_parser:
    class_name: DefaultModelsParser
    output_file: /path/to/default_models_parser.dart
  # Specific configs
  keyed_parsers:
    # Individual parser configs go here.
    - network_models_parser:
        class_name: NetworkModelsParser
        output_file: /path/to/network_models_parser.dart
    - ipc_models_parser:
        class_name: IpcModelsParser
        output_file: /path/to/ipc_models_parser.dart
```

Note: Use your preferred values for `class_name` and `output_file`.

## Usage

1. Annotate your model classes with `@JsonCodable` and apply required values if needed
   (See [`JsonCodable`](../parser_annotations/lib/src/json_codable.dart)
   from [`parser_annotations`](../parser_annotations) package)
2. Run the code generator
3. Use the generated parser in your code

### Run the generator

```bash
dart run build_runner build --delete-conflicting-outputs
```

Note: It is recommended to run a `flutter clean` and `flutter pub get` before running the generator.

## Example

See the [example](example/example.dart) for a complete demonstration.

## License

Click [here](../LICENSE) to see the license.