# clean_arch_lint

Analysis server plugin to enforce clean architecture.

## Installation

#### From pub.dev (Not yet available, use git based dependency management for now)

Add this to your `pubspec.yaml`

```yaml
dev_dependencies:
  clean_arch_lint: ^0.0.1
```

#### Or, From Git repo (Internal members only)

```yaml
dev_dependencies:
  clean_arch_lint:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: clean_arch_lint
      ref: main
```

## Getting started

### 1. Register the analyzer plugin in `analysis_options.yaml`.

```yaml
plugins:
  clean_arch_lint:
    path: ../clean_arch_lint
    diagnostics:
      clean_arch_dependency_direction: true
```

Should be added as a top level block, i.e., at the same level as `include`.

### 2. Create a `clean_arch_lint_config.yaml` file at the root of your project.

```yaml
# ==========================================
# Configuration for `clean_arch_lint` plugin
# ==========================================

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
  # (Default: logs/analysis_plugins/clean_arch_lint)
  log_dir_relative_path: logs/analyzer_plugins/clean_arch_lint

# Global Scan Configuration: Controls which project directories are scanned.
scan_config:
  # Scan the `lib/` directory (default: true)
  scan_lib_dir: true
  # Scan the `test/` directory (default: false)
  scan_test_dir: false

# Config for `clean_arch_dependency_direction` rule
clean_arch_dependency_direction:
  # Name of the domain folder(s) in the project (default: 'domain')
  domain_dir_name: domain
  # Exclude Dart core packages from analysis (default: true)
  # e.g., dart:core, dart:async, etc.
  exclude_core_dart_packages: true
  # Project paths to exclude from analysis (default: [])
  # Paths should be relative to `lib/` or `test/`.
  # Example: To exclude `lib/core/*`, write `core/*`
  excluded_project_paths:
    - core/
  # External library packages to exclude from analysis (default: [])
  # Specify package names as strings
  # Example: equatable, freezed, json_serializable
  excluded_library_packages:
    - equatable
```

The plugin looks for `clean_arch_lint_config.yaml` in the package root. If the file is missing
or invalid, default values are used.

### 3. Verify

Run `flutter pub get`, then run `flutter analyze` to verify the plugin is enabled and reporting
diagnostics. You may also want to restart the analysis server after each change to the analyzer
config (including initial setup).

## Example

See the [`app_template`](../app_template) project for a complete demonstration.

## License

Click [here](../LICENSE) to see the license.
