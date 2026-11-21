# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-11-18

### Added

- Initial release, with the reading moved out of `media_provider_android`
  2.0.0, for any `content://` URI rather than only `MediaStore` items.
- `openReadSession`: reads the content behind a URI, by path when the app can
  read the file, otherwise through a file descriptor or a platform stream. A
  descriptor its provider watches, such as a pipe, is read through the
  platform, so the provider learns whether the read finished or was
  cancelled.
- `openThumbnailReadSession`: reads the thumbnail of the content behind a URI
  at a requested size, the way `ContentResolver.loadThumbnail` does: the
  content's provider is asked first, and a thumbnail that already fits is read
  as it is. One much larger than requested is scaled down to close to the
  size, and one meant to be shown rotated is rotated upright (a HEIF image by
  its container's rotation, other images by their EXIF tag); both on by
  default, through `OpenThumbnailReadRequest.scaleDownToSize` and
  `rotateUpright`. When the provider has none, or gives the content itself
  (as a document provider does for a video, or an image without an embedded
  thumbnail), the thumbnail is made from the content: a frame of a video, or
  the image decoded scaled down.
- `ContentReadSession`: reads the content once, as a stream of chunks or all
  at once, and closes itself when done.
- `openWriteSession`: writes existing content, replacing it or adding to its
  end, through a file descriptor. A descriptor its provider watches, such as a
  pipe or a file it uploads once closed, is written through the platform, so
  the provider learns whether the write finished or was aborted.
- `ContentWriteSession`: writes the content in pieces or from a stream, then
  closes after the content is synced to the storage, so a full volume is
  reported as `NotEnoughSpaceException` rather than lost; or aborts.
- Typed exceptions for each operation's failures, such as
  `ContentNotFoundException`, `PermissionDeniedException` and
  `NotEnoughSpaceException`.
