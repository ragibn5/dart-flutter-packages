import 'package:media_provider_platform_interface/src/media_type.dart';
import 'package:meta/meta.dart';

/// A media item managed by the platform's media library.
@immutable
class MediaItem {
  /// What kind of media the item is.
  final MediaType type;

  /// Platform identifier of the item.
  ///
  /// Android: the `MediaStore` row ID.
  final String id;

  /// Platform URI for opening the item.
  ///
  /// Android: a `content://` URI.
  final String uri;

  /// File name, including extension.
  ///
  /// Android: read from `DISPLAY_NAME`.
  ///
  /// `null` if unknown.
  final String? name;

  /// MIME type, e.g. `image/jpeg`.
  ///
  /// `null` if unknown.
  final String? mimeType;

  /// File size in bytes.
  ///
  /// `null` if unknown.
  final int? sizeInBytes;

  /// When the item was added to the device's media library, in milliseconds
  /// since epoch.
  ///
  /// Android: converted from `DATE_ADDED`, which is in seconds.
  ///
  /// `null` if unknown.
  final int? dateAddedInMillis;

  /// When the file was last modified, in milliseconds since epoch.
  ///
  /// Android: converted from `DATE_MODIFIED`, which is in seconds.
  ///
  /// `null` if unknown.
  final int? dateModifiedInMillis;

  /// Name of the storage volume the file was in.
  ///
  /// - for primary shared storage, it is `external_primary`.
  /// - for secondary shared storage, it is the lowercased volume UUID.
  /// - if the volume cannot be resolved, it is `null`.
  final String? volumeName;

  /// Directory relative to the storage volume root, e.g. `DCIM/Camera/`.
  ///
  /// Empty if the file sits directly in the volume root, `null` if unknown.
  final String? relativePath;

  /// Whether the item is still being written.
  ///
  /// `null` if unsupported by the device (Android: below API 29).
  final bool? isPending;

  /// Whether the item is in the trash.
  ///
  /// `null` if unsupported by the device (Android: below API 30).
  final bool? isTrashed;

  /// Whether the item is marked as favorite.
  ///
  /// `null` if unsupported by the device (Android: below API 30).
  final bool? isFavorite;

  const MediaItem({
    required this.type,
    required this.id,
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
