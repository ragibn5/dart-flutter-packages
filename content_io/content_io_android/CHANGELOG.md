# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-11-18

### Added

- Initial release, with the reading moved out of `media_provider_android`
  2.0.0, for any `content://` URI rather than only `MediaStore` items.
- `openReadSession`: reads the content behind a URI, by path when the app can
  read the file, otherwise through a file descriptor or a platform stream.
- `openThumbnailReadSession`: reads the thumbnail of the content behind a URI
  at a requested size, without reading the content itself.
- `ContentReadSession`: reads the content once, as a stream of chunks or all
  at once, and closes itself when done.
- `openWriteSession`: writes existing content, replacing it or adding to its
  end, through a file descriptor or a platform stream.
- `ContentWriteSession`: writes the content in pieces or from a stream, then
  closes after the content is synced to the storage, so a full volume is
  reported as `NotEnoughSpaceException` rather than lost; or aborts.
- Typed exceptions for each operation's failures, such as
  `ContentNotFoundException`, `PermissionDeniedException` and
  `NotEnoughSpaceException`.
