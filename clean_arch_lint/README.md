# clean_arch_lint

Analysis server plugin to enforce clean architecture.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dev_dependencies:
  clean_arch_lint: ^1.0.0
```

#### Or, From Git repo

```yaml
dev_dependencies:
  clean_arch_lint:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: clean_arch_lint
      ref: clean_arch_lint-1.0.0
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
  # Exclude Dart core packages from analysis (default: true)
  # e.g., dart:core, dart:async, etc.
  exclude_core_dart_packages: true
  # Name(s) of domain folder(s) in the project (default: ['domain'])
  domain_dir_names:
    - domain
  # Package-root-relative paths to exclude from analysis (default: [])
  # Example: To exclude `lib/core/*`, write `lib/core/`
  excluded_project_paths:
    - lib/core/
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

## Violations

The `clean_arch_dependency_direction` rule reports the following violations for files inside any
directory listed in `domain_dir_names`:

| Import type                                                       | Violation message                         | Condition                                                                             |
|-------------------------------------------------------------------|-------------------------------------------|---------------------------------------------------------------------------------------|
| Own-package (relative or `package:self/`) pointing outside domain | `non-domain import in domain layer.`      | Import target is not in the same domain directory and not in `excluded_project_paths` |
| Third-party package                                               | `library package import in domain layer.` | Package not in `excluded_library_packages`                                            |
| `dart:*` SDK                                                      | `core dart import in domain layer.`       | `exclude_core_dart_packages` is `false`                                               |

Domain-to-domain imports within the **same domain directory** are allowed.
Imports from other features' domain directories are also blocked (treated as non-domain).

## Example

See the [`app_template`](../app_template) project for a complete demonstration.
