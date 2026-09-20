# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-08-31

### Changed

- **Breaking Change**: `GuardResult` subclasses now require `current` and specific target context parameters in their constructors:
  - `ContinueNavigation` requires `current` and `next`.
  - `BlockNavigation` requires `current` and `blocked`.
  - `RedirectNavigation` requires `current` and `redirectRoute`.
- Core models (`RouteInfo`, `RouteContext`, and `GuardResult` subclasses) now implement value-based equality (`operator ==` and `hashCode`), making them safe for comparison and use in collections.

## [1.0.0] - 2026-08-30

### Added

- Initial version.
