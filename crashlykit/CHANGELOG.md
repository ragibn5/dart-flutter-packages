# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-11-10

### Changed

- **Breaking:** `setSessionData(userId, collectionEnabled:)` is split into
  `setUserId(String? userId)` and
  `setCollectionEnabled({required bool enabled})`, so the user's collection
  choice no longer depends on, or changes with, the session. Migrate by
  calling both, or only the one you need.
- `setUserId` accepts `null`, which clears the user ID.
- `FirebaseCrashlyticsService.setCollectionEnabled(enabled: false)` also
  deletes the reports kept on the device while collection was off.

## [1.0.0] - 2026-08-29

### Added

- Initial release.
