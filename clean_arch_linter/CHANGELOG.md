# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.5] - 2026-08-02

### Changed

- Updated docs.
- Updated `analysis_server_plugin_core` dependency to `^1.1.5`.

## [2.0.4] - 2026-07-29

### Changed

- Updated docs.
- Updated `analysis_server_plugin_core` dependency to `^1.1.4`.

## [2.0.3] - 2026-07-26

### Changed

- Updated internal dependencies.

## [2.0.2] - 2026-07-26

### Added

- New rule: `cross_layer_import` — flags own-package imports that leave the domain layer.
- New rule: `third_party_import` — flags third-party package imports in domain files.
- New rule: `dart_sdk_import` — flags `dart:*` SDK imports in domain files.
- Top-level `domain_config` block for shared domain settings.

### Changed

- **Breaking:** Replaced the monolithic `dependency_direction_rule` with three modular rules:
    - `cross_layer_import`
    - `third_party_import`
    - `dart_sdk_import`

  See the [README](README.md) shipped with this release for more details.

- `domain_dir_names` moved from `clean_arch_dependency_direction` to the new top-level `domain_config` block.

- Updated dependency `analysis_server_plugin_core` to `^1.1.1`.

### Removed

- Redundant path-based plugin registration syntax from README.

### Fixed

- Git plugin registration syntax in README — now shows the correct `git:` block.

## [1.0.0] - 2026-07-21

### Added

- Initial version.
