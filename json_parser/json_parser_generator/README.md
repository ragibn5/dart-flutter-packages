# parser

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

#### From pub.dev (Not yet available, use git based dependency management for now)

Add this to your `pubspec.yaml`

```yaml
dependencies:
  json_parser_generator: ^0.0.1
```

#### Or, From Git repo (Internal members only)

```yaml
dependencies:
  json_parser_generator:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: json_parser/json_parser_generator
      ref: main
```

### Example

See the [example](example/example.dart) for a complete demonstration.

## License

Click [here](../../LICENSE) to see the license.