# app_analyzer

A custom analyzer plugin for flutter apps.

## Overview

`app_analyzer` is used to enforce our coding standards and recommendations for flutter
apps.

## Installation

#### From pub.dev (Not yet available, use git based dependency management for now)

Add this to your `pubspec.yaml`

```yaml
dev_dependencies:
  app_analyzer: ^0.0.1
```

#### Or, From Git repo (Internal members only)

```yaml
dev_dependencies:
  app_analyzer:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: app_analyzer
      ref: main
```

## Configuration

Add this to your [`analysis_options.yaml`](analysis_options.yaml)

```yaml
analyzer:
  plugins:
    - app_analyzer
```

## Get started

### After installing and configuring, make sure you restart your analysis server for it to take effect.

## License

Click [here](../LICENSE) to see the license.