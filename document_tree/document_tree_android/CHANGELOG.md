# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-11-18

### Added

- `getDocument`: describes the file or folder at a path, or returns `null`
  when there's none.
- `createDirectory`: creates a folder in an existing folder.
- `createDocument`: creates a file in an existing folder, with optional bytes
  as its content, for small files written in one go.
- `renameDocument`: renames a file or folder in its folder.
- `moveDocument`: moves a file or folder into another folder of the same
  tree, keeping its name.
- `deleteDocument`: deletes a file, or a folder with everything in it.
- `DocumentOperationUnsupportedException`, for a provider that can't rename
  or move a document.

### Changed

- **Breaking:** every operation that creates or renames a document fails with
  `DocumentAlreadyExistsException` when a document already has the name.
  `CopyDocumentRequest.overwrite` is removed.
- **Breaking:** `copyDocument` no longer creates the missing folders on the
  way; it fails with `DocumentNotFoundException` when the folder isn't there.
  Use `createDirectory` first.
- **Breaking:** `DocumentNotFoundException` is also a `DocumentWriteException`
  now, and `DocumentWriteException` has a new subtype, so a `switch` over it
  needs the new cases.

### Fixed

- `copyDocument` reports `NotEnoughSpaceException` when the volume fills up,
  instead of succeeding with part of the file lost: the content is now synced
  to the storage before the copy is reported done.

## [1.0.0] - 2026-11-16

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
