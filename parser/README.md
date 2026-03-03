# parser

A lightweight, flexible parser for encoding and decoding data in Dart & Flutter applications.

## Overview

`parser` is a type-safe parser that simplifies the process of serializing and deserializing
data. It provides a consistent interface for encoding objects to various formats and decoding them
back to strongly-typed Dart objects.

## Features

- Type-safe encoding and decoding
- Built-in JSON parsing capability
- Extensible architecture for custom parsers

## Installation

#### From pub.dev (Not yet available, use git based dependency management for now)

Add this to your `pubspec.yaml`

```yaml
dependencies:
  parser: ^0.0.1
```

#### Or, From Git repo (Internal members only)

```yaml
dependencies:
  parser:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: parser
      ref: main
```

### Usage

1. Create your parser implementation, or use the built-in parsers.
    - Currently available built-in parser implementations:
        - [JsonParser](lib/src/parser_impls/json_parser.dart): Supports primitive and custom types.
    - Use [Parser](lib/src/parser_base.dart) to create your custom parser implementations.
2. Register decoders for your custom types
3. Use the parser to encode and decode data

### Example

See the [example](example/example.dart) for a complete demonstration.

## License

Click [here](../LICENSE) to see the license.