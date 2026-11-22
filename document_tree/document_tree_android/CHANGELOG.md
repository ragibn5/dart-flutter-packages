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
- `parentUri` on `CopyDocumentRequest`, `CreateDirectoryRequest` and
  `GetDocumentRequest`, and `parentUri` and `newParentUri` on
  `MoveDocumentRequest`: a folder's URI from an earlier result. While that
  folder still has the name its path gives it, it's used as it is instead of
  being found by walking the path.
- `MoveDocumentRequest.skipNameCheck`: moves without first listing the
  destination folder to check the name, for a caller that knows the name is
  free. A move that then fails on a taken name still fails with
  `DocumentAlreadyExistsException`; a provider that replaces instead of
  failing does so, as Android's local storage doesn't.

- `CopyDocumentRequest.hashAlgorithm`: hashes the copied bytes with SHA-256
  as they're written, so the hash is of exactly what the copy holds, with no
  second read.

### Changed

- **Breaking:** `copyDocument` returns a `CopiedDocument`: the copy as
  `document`, and its `contentHash` when the request asked for one.
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

- `DocumentTree.location` is confirmed instead of read off the storage
  provider's document ID, whose `<volume id>:<relative path>` shape Android
  doesn't document. On Android 10 and later it comes from the folder's
  MediaStore row. On Android 7 to 9 the document ID is still read, but only
  for a mounted volume, and, with the storage permission, only when that
  folder holds the tree's entries. It's `null` when it can't be confirmed,
  where a different ID shape could before give a wrong location.
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
