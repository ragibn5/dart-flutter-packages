# parser_analyzer

Collection of analysis tools for public components of [parser](../parser).

## Overview

Collection of analysis tools specific to the public components of [parser](../parser)
package. Provides various compile time compatibility checking and more.

This package is designed to an add-on of the analyzer plugin of your application/project.

Please see the [`flutter_app_analyzer`](../app_analyzer), which is our
official analyzer plugin for flutter apps/projects.

You may create your own analyzer plugin and use this package as an add on,
or use `flutter_app_analyzer` which includes this and other analyzers
used by our organization.

## Installation

#### From pub.dev (Not yet available, use git based dependency management for now)

Add this to your analyzer plugin's `pubspec.yaml`

```yaml
dependencies:
  parser_analyzer: ^0.0.1
```

#### Or, From Git repo (Internal members only)

```yaml
dependencies:
  parser_analyzer:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: parser_analyzer
      ref: main
```

To signal the analyzer (or analyzer plugin) to perform analysis, you need to annotate your model
classes with [@JsonCodable](../parser_annotations/lib/src/json_codable.dart) from
the [parser_annotations](../parser_annotations) package.

So, you may also want to add this to your application/project's `pubspec.yaml`.

```yaml
dependency:
  parser_annotations:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: parser_annotations
      ref: main
```

Note, this `parser_annotations` is for signaling the analyzer/analyzer plugin and is not a
requirement for the analyzer plugin package(unless your plugin package uses it somehow), instead
this package is generally used in **main application/project**, which in turn, uses the plugin
package.

## Usage

Annotate your model classes with [JsonCodable](../parser_annotations/lib/src/json_codable.dart)
from the [parser_annotations](../parser_annotations) package.

You should see the compile time checking take effect right away
(via the analyzer plugin which uses this package).

Note:
If the analyzer's checking do not start right away, please do the following:

1. Go to `~/.dartServer/.plugin_manager/` directory, and delete all the files/folders within.
2. Restart IDE.

## Example

See the [example](example/example.dart) for a complete demonstration.

## License

Click [here](../LICENSE) to see the license.