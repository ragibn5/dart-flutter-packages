# media_provider_android

Reads the photos and videos of Android's `MediaStore`, and the storage volumes they're on.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  media_provider_android: ^1.0.0
```

#### Or, From Git repo

```yaml
dependencies:
  media_provider_android:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: media_provider/media_provider_android
      ref: media_provider_android-1.0.0
```

## Features

- List the device's storage volumes: primary storage, SD cards and USB drives, with their state and space.
- Query photos and videos on chosen volumes, optionally within one folder.
- Read an item's bytes, or its thumbnail, as a stream or all at once.
- Share items, or open one in another app, through the system chooser.

## Permissions

The plugin neither declares nor requests permissions: the host app declares them in its own `AndroidManifest.xml`, and asks for them before querying or reading.

| Android version        | Permissions                                                                                      |
|------------------------|--------------------------------------------------------------------------------------------------|
| 13 (API 33) and up     | `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`; on 14 and up, also `READ_MEDIA_VISUAL_USER_SELECTED` to tell selected-only access apart |
| 12L (API 32) and below | `READ_EXTERNAL_STORAGE`, with `android:maxSdkVersion="32"`                                       |
| 10 (API 29) and up     | `ACCESS_MEDIA_LOCATION`, if photos' locations must be read: without it, Android removes them     |

```xml
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission
    android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32" />
```

Without them, a query returns only the items the app owns, and reading an item fails with `PermissionDeniedException`.

## Get started

### 1. Find the volumes

```dart
final mediaProvider = MediaProviderAndroid();

final volumes = await mediaProvider.getVolumes();
final sdCard = volumes.firstWhere(
  (volume) => volume.identity.type == VolumeType.sdCard,
);
```

### 2. Query media

Ask for the media types and the volumes to search. A volume can be limited to a folder with `relativePathScope`.

```dart
final items = await mediaProvider.getMedia(
  QuerySpec(
    types: const {MediaType.photo, MediaType.video},
    volumes: {
      const VolumeSpec.primary(relativePathScope: 'DCIM/Camera'),
      VolumeSpec.external(uuid: sdCard.identity.uuid!),
    },
  ),
);
```

### 3. Read an item

A session reads an item once, and closes itself when done.

```dart
// Small items: all at once.
final session = await mediaProvider.openReadSession(
  OpenMediaReadRequest.fromItem(items.first),
);
final bytes = await session.readAsBytes();

// Large items, such as videos: as a stream of chunks.
final videoSession = await mediaProvider.openReadSession(
  OpenMediaReadRequest.fromItem(video),
);
await videoSession.openRead().pipe(file.openWrite());
```

A thumbnail is read the same way, without reading the item itself:

```dart
final thumbnailSession = await mediaProvider.openThumbnailReadSession(
  OpenThumbnailReadRequest.fromItem(
    items.first,
    size: const ThumbnailSize(width: 256, height: 256),
  ),
);
```

### 4. Share or open items

```dart
await mediaProvider.shareMedia(
  ShareMediaRequest.fromItems(items, chooserTitle: 'Share'),
);

await mediaProvider.openMediaWith(
  OpenMediaWithRequest.fromItem(items.first, chooserTitle: 'Open with'),
);
```

## Errors

Each operation reports its failures as its own exceptions:

| Operation                                       | Exceptions                                                                                                   |
|-------------------------------------------------|--------------------------------------------------------------------------------------------------------------|
| `getMedia`                                      | `MediaQueryException`: `InvalidQueryError`                                                                   |
| `openReadSession`, `openThumbnailReadSession`   | `MediaReadOpenException`: `PermissionDeniedException`, `MediaNotFoundException`, `InvalidOpenRequestError`, `UnsupportedOperationException` |
| `MediaReadSession` reads                        | `MediaReadException`: `ReadException`, `SessionNotFoundException`, `InvalidReadRequestError`                 |
| `shareMedia`, `openMediaWith`                   | `MediaActionException`: `NoActivityException`, `ActionNotPermittedException`, `InvalidActionRequestError`    |

> Note: An unexpected platform failure arrives as a `PlatformException`.

## Example

See the [example](example/lib/main.dart) for a complete demonstration.
