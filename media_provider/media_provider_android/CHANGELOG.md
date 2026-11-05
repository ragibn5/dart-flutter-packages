# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Initial release.
- `getVolumes`: lists the device's storage volumes, with each one's type
  (primary, SD card, USB drive), state, path, capacity and available space.
  The sizes are `null` when a volume's file system can't be read.
- `getMedia`: queries `MediaStore` for photos and videos on the given volumes,
  optionally limited to a folder. Each item comes with its `MediaStore` columns
  and, when it's backed by a file, its location on its volume.
- `openReadSession`: reads an item's bytes, by path when the app can read the
  file, otherwise through a file descriptor or a platform stream.
- `openThumbnailReadSession`: reads an item's thumbnail at a requested size,
  without reading the item itself.
- `MediaReadSession`: reads an item once, as a stream of chunks or all at once,
  and closes itself when done.
- `shareMedia`: shows the system share sheet for one or more items.
- `openMediaWith`: shows the apps that can open an item.
- Typed exceptions for each operation's failures, such as
  `PermissionDeniedException`, `MediaNotFoundException` and
  `NoActivityException`.
