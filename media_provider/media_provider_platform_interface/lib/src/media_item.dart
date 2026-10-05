import 'dart:io';

import 'package:media_provider_platform_interface/src/media_type.dart';
import 'package:meta/meta.dart';

/// A media item managed by the platform's media library.
@immutable
class MediaItem {
  /// What kind of media the item is.
  final MediaType type;

  /// Unique identifier of the item.
  ///
  /// Platform values:
  /// - Android: the `MediaStore` row ID (`_ID`), as a string.
  final String id;

  /// Name of the host platform, obtained from [Platform.operatingSystem].
  final String osName;

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

  const MediaItem({
    required this.type,
    required this.id,
    required this.osName,
    required this.uri,
    required this.name,
    required this.mimeType,
    required this.sizeInBytes,
    required this.dateAddedInMillis,
    required this.dateModifiedInMillis,
    required this.volumeName,
    required this.relativePath,
    required this.isPending,
    required this.isTrashed,
    required this.isFavorite,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaItem &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id &&
          osName == other.osName &&
          uri == other.uri &&
          name == other.name &&
          mimeType == other.mimeType &&
          sizeInBytes == other.sizeInBytes &&
          dateAddedInMillis == other.dateAddedInMillis &&
          dateModifiedInMillis == other.dateModifiedInMillis &&
          volumeName == other.volumeName &&
          relativePath == other.relativePath &&
          isPending == other.isPending &&
          isTrashed == other.isTrashed &&
          isFavorite == other.isFavorite;

  @override
  int get hashCode => Object.hash(
    type,
    id,
    osName,
    uri,
    name,
    mimeType,
    sizeInBytes,
    dateAddedInMillis,
    dateModifiedInMillis,
    volumeName,
    relativePath,
    isPending,
    isTrashed,
    isFavorite,
  );

  @override
  String toString() {
    return [
      'MediaItem {',
      ' type: $type,',
      ' id: $id,',
      ' osName: $osName,',
      ' uri: $uri,',
      ' name: $name,',
      ' mimeType: $mimeType,',
      ' sizeInBytes: $sizeInBytes,',
      ' dateAddedInMillis: $dateAddedInMillis,',
      ' dateModifiedInMillis: $dateModifiedInMillis,',
      ' volumeName: $volumeName,',
      ' relativePath: $relativePath,',
      ' isPending: $isPending,',
      ' isTrashed: $isTrashed,',
      ' isFavorite: $isFavorite',
      '}',
    ].join('\n');
  }
}
