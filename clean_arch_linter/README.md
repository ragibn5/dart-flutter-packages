# clean_arch_linter

Analysis server plugin to enforce clean architecture.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dev_dependencies:
  clean_arch_linter: ^1.0.0
```

#### Or, From Git repo

```yaml
dev_dependencies:
  clean_arch_linter:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: clean_arch_linter
      ref: clean_arch_linter-1.0.0
```

## 🚀 Getting started

### 1. Register the analyzer plugin in `analysis_options.yaml`

#### If installed from pub.dev

```yaml
plugins:
  clean_arch_linter:
    diagnostics:
      cross_layer_import: true
      third_party_import: true
      dart_sdk_import: true
```

#### If installed from git or a local path

```yaml
plugins:
  clean_arch_linter:
    path: ../clean_arch_linter
    diagnostics:
      cross_layer_import: true
      third_party_import: true
      dart_sdk_import: true
```

Should be added as a top level block, i.e., at the same level as `include`.

### 2. (Optional) Create a `clean_arch_linter_config.yaml`

Place the file at the root of your project to customize rule behavior. **The file is entirely optional** — if omitted, the plugin uses these defaults:

| Setting                   | Default      |
|---------------------------|--------------|
| Logging                   | Disabled     |
| Scanned directories       | `lib/` only  |
| Domain directory names    | `['domain']` |
| Excluded project paths    | `[]`         |
| Excluded library packages | `[]`         |
| Excluded dart packages    | `[]`         |

Below is a sample config with all available options. Every field is optional — omitted values fall back to the defaults above. The packages and paths listed here are illustrative examples, not recommendations. Replace them with values that suit your project.

```yaml
# ==========================================
# Configuration for `clean_arch_linter` plugin
# ==========================================

# Global log configuration: controls diagnostic logging for all rules.
log_config:
  enabled: true        # Enable or disable logging (default: false)
  allow_info: false    # Allow info-level messages (default: false)
  allow_warning: true  # Allow warning-level messages (default: true)
  allow_error: true    # Allow error-level messages (default: true)
  # Relative path (from project root) where log files are saved.
  # default: logs/analyzer_plugins/clean_arch_linter
  log_dir_relative_path: logs/analyzer_plugins/clean_arch_linter

# Global scan configuration: controls which directories are scanned.
scan_config:
  scan_lib_dir: true   # Scan the lib/ directory (default: true)
  scan_test_dir: false # Scan the test/ directory (default: false)

# Shared domain configuration.
domain_config:
  # Names of directories considered "domain" layers (default: ['domain']).
  domain_dir_names:
    - domain

# Per-rule configuration
rules:
  # cross_layer_import: flags own-package imports that leave the domain layer.
  cross_layer_import:
    # Package-root-relative paths to exclude from checks (default: []).
    excluded_project_paths:
      - lib/core/          # example path — replace with your own

  # third_party_import: flags third-party package imports in domain files.
  third_party_import:
    # Package names to exclude from checks (default: []).
    excluded_library_packages:
      - dartz              # example package — replace with your own
      - equatable

  # dart_sdk_import: flags dart:* SDK imports in domain files.
  dart_sdk_import:
    # Dart SDK package names to exclude (default: []).
    # These are the part after "dart:" — e.g. "core", "async", "io".
    excluded_dart_packages:
      - async              # example package — replace with your own
      - collection
```

### 3. Verify

Run `flutter pub get`, then run `flutter analyze` to verify the plugin is enabled and reporting diagnostics. You may also want to restart the analysis server after each change to the analyzer config (including initial setup).

## 🔍 Rules

All three rules apply only to files located inside a **domain directory** (any directory matching a name in `domain_dir_names`, e.g. `domain/`). Files outside domain directories are never flagged.

### `cross_layer_import`

Reports own-package imports (relative or `package:self/`) that point outside the file's own domain directory.

| Import target                                        | Reported? | Why                                     |
|------------------------------------------------------|-----------|-----------------------------------------|
| Same domain directory                                | No        | Allowed internal domain import          |
| Different feature's domain directory                 | Yes       | Cross-domain dependency                 |
| Outside any domain directory (e.g. `data/`, `core/`) | Yes       | Non-domain dependency from domain layer |
| Path in `excluded_project_paths`                     | No        | Explicitly allowed                      |

### `third_party_import`

Reports third-party package imports (`package:some_package/...`) from domain components.

| Import type      | Reported? | Why                          |
|------------------|-----------|------------------------------|
| Own package      | No        | Not third-party              |
| Excluded package | No        | Explicitly allowed           |
| Other packages   | Yes       | Domain should avoid coupling |

### `dart_sdk_import`

Reports Dart SDK imports (`dart:...`) from domain components.

| Import type            | Reported? | Why                              |
|------------------------|-----------|----------------------------------|
| Excluded dart packages | No        | Explicitly allowed               |
| Other dart packages    | Yes       | Domain should avoid SDK coupling |

## 🐛 Debugging

To see diagnostic logs from the plugin, enable logging in `clean_arch_linter_config.yaml`:

```yaml
log_config:
  enabled: true
```

Log files are written to the path specified by `log_dir_relative_path` (defaults to `logs/analyzer_plugins/clean_arch_linter/` relative to your project root). Each run creates a daily log file named `LOG-dd-MM-yyyy.log`.

You can control which severity levels are logged. By default, `info` is disabled as it is very verbose (logs every skipped file and ignored import). To enable all levels:

```yaml
log_config:
  enabled: true
  allow_info: true     # Disabled by default — very verbose
  allow_warning: true  # Enabled by default
  allow_error: true    # Enabled by default
```

If you are not seeing expected diagnostics, try:

- Restarting the analysis server (`flutter analyze` or restart the IDE's Dart analysis server).
- Ensuring the file is inside a directory that matches `domain_dir_names` (default: `domain/`).
- Ensuring `scan_test_dir: true` if the file is under `test/`.
- Checking your `clean_arch_linter_config.yaml` for invalid YAML syntax or incorrect indentation. If the file is malformed, the plugin may crash or fall back to default silently.

## 📄 Example

See the [`app_template`](../app_template) project for a complete demonstration.
