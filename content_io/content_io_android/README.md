# content_io_android

Reads and writes the bytes behind Android `content://` URIs, such as photos, videos and documents, and reads their thumbnails.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  content_io_android: ^1.0.0
```

#### Or, From Git repo

```yaml
dependencies:
  content_io_android:
    git:
      url: https://github.com/ragibn5/dart-flutter-packages.git
      path: content_io/content_io_android
      ref: content_io_android-1.0.0
```

## Features

- Read the content behind any `content://` URI, such as a `MediaStore` item or a document in a picked folder, as a stream or all at once.
- Read the thumbnail of the content behind a URI, at a requested size: the provider's own when it has one, scaled down and rotated upright as needed, otherwise made from the content.
- Write existing content, replacing it or adding to its end, in pieces or from a stream.
- Learn about a full volume when the write closes, not after the data is silently lost.
- Read and write on worker isolates or background threads, through file descriptors when the provider offers them.

## Permissions

None: the plugin needs whatever the content's provider asks for, which the host app declares or obtains. For example, `MediaStore` items need media permissions, and a document in a folder the user picked needs that folder's grant.

## Get started

### 1. Read

A session reads the content once, and closes itself when done.

```dart
final contentIo = ContentIoAndroid();

// Small content: all at once.
final session = await contentIo.openReadSession(
  const OpenReadRequest(uri: 'content://media/external/images/media/42'),
);
final bytes = await session.readAsBytes();

// Large content, such as videos: as a stream of chunks.
final videoSession = await contentIo.openReadSession(
  OpenReadRequest(uri: video.uri, filePath: video.path),
);
await videoSession.openRead().pipe(file.openWrite());
```

A thumbnail is read the same way. The provider's thumbnail is read as it is when it fits; one much larger than requested is scaled down to close to the size, and one meant to be shown rotated is rotated upright (`scaleDownToSize` and `rotateUpright`, both on by default). Only when the provider has none, as for a video read through a document tree, is the thumbnail made from the content itself:

```dart
final thumbnailSession = await contentIo.openThumbnailReadSession(
  const OpenThumbnailReadRequest(
    uri: 'content://media/external/images/media/42',
    size: ThumbnailSize(width: 256, height: 256),
  ),
);
```

### 2. Write

The content must exist; create a new document with `document_tree_android`'s `createDocument` first. A session writes the content once: `close` stores it, `abort` gives up.

```dart
final session = await contentIo.openWriteSession(
  OpenWriteRequest(uri: document.uri),
);
await session.write(utf8.encode('First line\n'));
await session.write(utf8.encode('Second line\n'));
await session.close();

// Add to the end, from a stream; closes when the stream ends.
final appendSession = await contentIo.openWriteSession(
  OpenWriteRequest(uri: document.uri, mode: WriteMode.append),
);
await appendSession.writeStream(readSession.openRead());
```

## Errors

Each operation reports its failures as its own exceptions:

| Operation                                                         | Exceptions                                                                                                                         |
|-------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------|
| `openReadSession`, `openThumbnailReadSession`, `openWriteSession` | `ContentOpenException`: `ContentNotFoundException`, `PermissionDeniedException`, `InvalidOpenRequestError`, `UnsupportedOperationException` |
| `ContentReadSession` reads                                        | `ContentReadException`: `ReadException`, `SessionNotFoundException`, `InvalidReadRequestError`                                     |
| `ContentWriteSession` writes and `close`                          | `ContentWriteException`: `NotEnoughSpaceException`, `WriteException`, `WriteSessionNotFoundException`, `InvalidWriteRequestError` |

> Note: An unexpected platform failure arrives as a `PlatformException`.

## Example

See the [example](example/lib/main.dart) for a complete demonstration.
