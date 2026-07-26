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

## 🚀 Getting started

### 1. Register the analyzer plugin in `analysis_options.yaml`

#### If installed from pub.dev

```yaml
plugins:
  json_parser_linter:
    diagnostics:
      json_parser_requirements: true
```

#### If installed from git or a local path

```yaml
plugins:
  json_parser_linter:
    path: ../json_parser/json_parser_linter
    diagnostics:
      json_parser_requirements: true
```

Should be added as a top level block, i.e., at the same level as `include`.

### 2. (Optional) Create a `json_parser_linter_config.yaml`

Place the file at the root of your project to customize logging and scan scope. **The file is entirely optional** — if omitted, the plugin uses these defaults:

| Setting             | Default     |
|---------------------|-------------|
| Logging             | Disabled    |
| Scanned directories | `lib/` only |

Below is a sample config with all available options. Every field is optional — omitted values fall back to the defaults above.

```yaml
# ==========================================
# Configuration for `json_parser_linter` plugin
# ==========================================

# Global log configuration: controls diagnostic logging for all rules.
log_config:
  enabled: true        # Enable or disable logging (default: false)
  allow_info: false    # Allow info-level messages (default: false)
  allow_warning: true  # Allow warning-level messages (default: true)
  allow_error: true    # Allow error-level messages (default: true)
  # Relative path (from project root) where log files are saved.
  # default: logs/analyzer_plugins/json_parser_linter
  log_dir_relative_path: logs/analyzer_plugins/json_parser_linter

# Global scan configuration: controls which directories are scanned.
scan_config:
  scan_lib_dir: true   # Scan the lib/ directory (default: true)
  scan_test_dir: false # Scan the test/ directory (default: false)
```

### 3. Verify

Run `flutter pub get`, then run `flutter analyze` to verify the plugin is enabled and reporting diagnostics. You may also want to restart the analysis server after each change to the analyzer config (including initial setup).

## 🔍 Rules

The rule applies only to **concrete classes** annotated with `@GenerateJsonParser`. Abstract classes and non-class declarations are ignored.

### `json_parser_requirements`

Reports missing or invalid `toJson` / `fromJson` members required for JSON parser generation.

| Check                                                          | Reported? | Why                                     |
|----------------------------------------------------------------|-----------|-----------------------------------------|
| Missing `toJson` instance method                               | Yes       | Required for serialization              |
| `toJson` is a getter, takes params, or has a wrong return type | Yes       | Signature must match generator contract |
| Missing both factory and static `fromJson`                     | Yes       | Required for deserialization            |
| `fromJson` has wrong params or return type                     | Yes       | Signature must match generator contract |
| Valid `toJson` + factory or static `fromJson`                  | No        | Meets requirements                      |
| Abstract class / non-class annotation target                   | No        | Not applicable                          |

Required shapes:

- Instance method: `Map<String, dynamic> toJson()` (or `Map<String, Object?>`)
- Factory: `factory YourClass.fromJson(Map<String, dynamic> json)` (or `Map<String, Object?>`), **or**
- Static method: `static YourClass fromJson(Map<String, dynamic> json)` (or `Map<String, Object?>`)

## 🐛 Debugging

To see diagnostic logs from the plugin, enable logging in `json_parser_linter_config.yaml`:

```yaml
log_config:
  enabled: true
```

Log files are written to the path specified by `log_dir_relative_path` (defaults to `logs/analyzer_plugins/json_parser_linter/` relative to your project root). Each run creates a daily log file named `LOG-dd-MM-yyyy.log`.

You can control which severity levels are logged. By default, `info` is disabled as it is very verbose. To enable all levels:

```yaml
log_config:
  enabled: true
  allow_info: true     # Disabled by default — very verbose
  allow_warning: true  # Enabled by default
  allow_error: true    # Enabled by default
```

If you are not seeing expected diagnostics, try:

- Restarting the analysis server (`flutter analyze` or restart the IDE's Dart analysis server).
- Ensuring the class is annotated with `@GenerateJsonParser` and is not abstract.
- Ensuring `scan_test_dir: true` if the file is under `test/`.
- Checking your `json_parser_linter_config.yaml` for invalid YAML syntax or incorrect indentation. If the file is malformed, the plugin may crash or fall back to default silently.

## 📄 Example

See the [`app_template`](../../app_template) project for a complete demonstration.
