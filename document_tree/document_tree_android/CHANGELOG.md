# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-11-13

### Added

- Initial release.
- `pickTree`: lets the user pick a folder through the system's picker,
  optionally starting at a given folder, and persists the app's access to it.
- `getTree`: describes a picked folder, or returns `null` when the app no
  longer holds its grant or it can't be reached.
- `releaseTree`: drops the app's access to a picked folder.
- `listDocuments`: lists a folder's files and folders, optionally all the way
  down, with each one's path, MIME type, size and whether it can be written.
- `copyDocument`: copies a file from any readable URI into a picked folder,
  creating the missing folders, and deletes a file it created if the copy
  fails.
- Typed exceptions for each operation's failures, such as
  `PickerAlreadyOpenException`, `TreeAccessLostException` and
  `NotEnoughSpaceException`.
