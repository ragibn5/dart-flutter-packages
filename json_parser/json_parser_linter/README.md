# json_parser_linter

Analysis server plugin to enforce json_parser compatible structures.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dev_dependencies:
  json_parser_linter: ^1.0.0
```

#### Or, From Git repo

```yaml
dev_dependencies:
  json_parser_linter:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: json_parser/json_parser_linter
      ref: json_parser/json_parser_linter-1.0.0
```

## Getting started

### 1. Register the analyzer plugin in `analysis_options.yaml`.

```yaml
plugins:
  json_parser_linter:
    path: ../json_parser/json_parser_linter
    diagnostics:
      json_parser_requirements: true
```

Should be added as a top level block, i.e., at the same level as `include`.

### 2. Create a `json_parser_linter_config.yaml` file at the root of your project.

```yaml
# ================================================
# Configuration for `json_parser_arch_lint` plugin
# ================================================

# Global Log Configuration: Controls logging for all rules.
log_config:
  # Enable or disable logging for all rules (default: false)
  enabled: true
  # Individual log levels (overrides `enabled`)
  # (Defaults - info: false, warning: true, error: true)
  allow_info: false
  allow_warning: true
  allow_error: true
  # Relative(to project root) path where logs will be saved
  # (Default: logs/analysis_plugins/clean_arch_linter)
  log_dir_relative_path: logs/analyzer_plugins/json_parser_linter

# Global Scan Configuration: Controls which project directories are scanned.
scan_config:
  # Scan the `lib/` directory (default: true)
  scan_lib_dir: true
  # Scan the `test/` directory (default: false)
  scan_test_dir: false
```

The plugin looks for `json_parser_linter_config.yaml` in the package root. If the file is
missing or invalid, default values are used.

### 3. Verify

Run `flutter pub get`, then run `flutter analyze` to verify the plugin is enabled and reporting
diagnostics. You may also want to restart the analysis server after each change to the analyzer
config (including initial setup).

## Example

See the [`app_template`](../../app_template) project for a complete demonstration.
