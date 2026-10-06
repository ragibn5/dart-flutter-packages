import 'package:media_provider_android/src/android_media_type.dart';
import 'package:meta/meta.dart';

/// A media item managed by the platform's media library.
@immutable
class AndroidMediaItem {
  /// What kind of media the item is.
  final AndroidMediaType type;

  /// Unique identifier of the item.
  ///
  /// Platform values:
  /// - Android: the `MediaStore` row ID (`_ID`), as a string.
  final String id;

  /// URI for opening the item.
  ///
  /// Platform values:
  /// - Android: a `content://` URI, openable through `ContentResolver`.
  final String? uri;

  /// File name, including extension.
  ///
  /// Platform values:
  /// - Android: read from `DISPLAY_NAME`. `null` if unknown.
  final String? name;

  /// MIME type.
  ///
  /// Platform values:
  /// - Android: read from `MIME_TYPE`, e.g. `image/jpeg`. `null` if unknown.
  final String? mimeType;

  /// File size in bytes.
  ///
  /// Platform values:
  /// - Android: read from `SIZE`. `null` if unknown.
  final int? sizeInBytes;

  /// When the item was added to the device's media library,
  /// in milliseconds since epoch.
  ///
  /// Platform values:
  /// - Android: converted from `DATE_ADDED`, which is in seconds. `null`
  ///   if unknown.
  final int? dateAddedInMillis;

  /// When the file was last modified, in milliseconds since epoch.
  ///
  /// Platform values:
  /// - Android: converted from `DATE_MODIFIED`, which is in seconds.
  ///   `null` if unknown.
  final int? dateModifiedInMillis;

  /// When the item was captured, in milliseconds since epoch.
  ///
  /// Platform values:
  /// - Android: read from `DATE_TAKEN`, which is already in milliseconds.
  ///   `null` below API 29.
  final int? dateTakenInMillis;

  /// Name of the storage volume the file was in.
  ///
  /// Platform values:
  /// - Android: derived from the file path, on all API levels.
  ///   - `external_primary` for primary shared storage.
  ///   - The lowercased volume UUID for secondary shared storage.
  ///   - `null` if the volume cannot be resolved.
  final String? volumeName;

  /// Directory relative to the storage volume root.
  ///
  /// Platform values:
  /// - Android: derived from the file path, on all API levels, with a
  ///   trailing slash, e.g. `DCIM/Camera/`. Empty if the file sits directly
  ///   in the volume root, `null` if the path cannot be resolved.
  ///
  /// Note: the path separators are NOT platform-specific, it is always `/`,
  /// for any platform.
  final String? relativePath;

  /// Package name of the app that owns the item.
  ///
  /// Platform values:
  /// - Android: read from `OWNER_PACKAGE_NAME`. `null` below API 29, and
  ///   `null` when no app owns the item.
  final String? ownerPackageName;

  /// Whether the item is still being written.
  ///
  /// Platform values:
  /// - Android: read from `IS_PENDING`. `null` below API 29.
  final bool? isPending;

  /// Whether the item is in the trash.
  ///
  /// Platform values:
  /// - Android: read from `IS_TRASHED`. `null` below API 30.
  final bool? isTrashed;

  /// Whether the item is marked as favorite.
  ///
  /// Platform values:
  /// - Android: read from `IS_FAVORITE`. `null` below API 30.
  final bool? isFavorite;

  /// Whether the item belongs to the device's downloads collection.
  ///
  /// Platform values:
  /// - Android: read from `IS_DOWNLOAD`. `null` below API 30.
  final bool? isDownloaded;

  const AndroidMediaItem({
    required this.type,
    required this.id,
    required this.uri,
    required this.name,
    required this.mimeType,
    required this.sizeInBytes,
    required this.dateAddedInMillis,
    required this.dateModifiedInMillis,
    required this.dateTakenInMillis,
    required this.volumeName,
    required this.relativePath,
    required this.ownerPackageName,
    required this.isPending,
    required this.isTrashed,
    required this.isFavorite,
    required this.isDownloaded,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AndroidMediaItem &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id &&
          uri == other.uri &&
          name == other.name &&
          mimeType == other.mimeType &&
          sizeInBytes == other.sizeInBytes &&
          dateAddedInMillis == other.dateAddedInMillis &&
          dateModifiedInMillis == other.dateModifiedInMillis &&
          dateTakenInMillis == other.dateTakenInMillis &&
          volumeName == other.volumeName &&
          relativePath == other.relativePath &&
          ownerPackageName == other.ownerPackageName &&
          isPending == other.isPending &&
          isTrashed == other.isTrashed &&
          isFavorite == other.isFavorite &&
          isDownloaded == other.isDownloaded;

  @override
  int get hashCode => Object.hash(
    type,
    id,
    uri,
    name,
    mimeType,
    sizeInBytes,
    dateAddedInMillis,
    dateModifiedInMillis,
    dateTakenInMillis,
    volumeName,
    relativePath,
    ownerPackageName,
    isPending,
    isTrashed,
    isFavorite,
    isDownloaded,
  );

  @override
  String toString() {
    return [
      'MediaItem {',
      ' type: $type,',
      ' id: $id,',
      ' uri: $uri,',
      ' name: $name,',
      ' mimeType: $mimeType,',
      ' sizeInBytes: $sizeInBytes,',
      ' dateAddedInMillis: $dateAddedInMillis,',
      ' dateModifiedInMillis: $dateModifiedInMillis,',
      ' dateTakenInMillis: $dateTakenInMillis,',
      ' volumeName: $volumeName,',
      ' relativePath: $relativePath,',
      ' ownerPackageName: $ownerPackageName,',
      ' isPending: $isPending,',
      ' isTrashed: $isTrashed,',
      ' isFavorite: $isFavorite,',
      ' isDownloaded: $isDownloaded',
      '}',
    ].join('\n');
  }
}
