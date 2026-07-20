# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-07-21

### Added

- `PathStringExtensions` on `String` with `normalizePathSeparators`, `ensureTrailingPathSeparator`, and `surroundingPathSeparator` for cross-platform path manipulation.
- `RuleContextExtensions` on `RuleContext` with `packageRelativeUnitPath(pathSeparator:)` for resolving file paths relative to the package root.
- README with installation instructions, quick-start guide, and component reference.

### Changed

- `PathStringExtensions` methods now take a required `pathSeparator` parameter instead of hardcoding `/`.
- `packageRelativeUnitPath` is now a method requiring a `pathSeparator` parameter.

### Fixed

- `ensureTrailingPathSeparator` now uses the provided `pathSeparator` instead of hardcoded `/`.
- `surroundingPathSeparator` now uses the provided `pathSeparator` instead of hardcoded `/`.
- `packageRelativeUnitPath` now correctly appends `pathSeparator` instead of `packageRoot` when the root lacks a trailing separator.

## [1.0.0] - 2026-07-18

### Added

- Core components to build a custom Dart analysis server plugin.
