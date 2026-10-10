import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:media_provider_android/src/models/media_type.dart';
import 'package:media_provider_android/src/models/volume_info.dart';
import 'package:meta/meta.dart';

part 'media_item.g.dart';

/// A single media file tracked by the Android `MediaStore`.
///
/// Fields here (most of them, unless noted) corresponds to a column defined
/// in `android.provider.MediaStore.MediaColumns`. See the documentation of
/// that class for more information about each field's possible values. If any
/// field's behavior deviates from the corresponding column documentation, it
/// is explicitly documented here, in the field's documentation.
@JsonSerializable()
@immutable
class MediaItem extends Equatable {
  /// The `MediaStore` collection this item belongs to.
  final MediaType type;

  /// The `MediaStore` row ID (`_ID`), as a string, for example `'42'`.
  ///
  /// Sourced from `BaseColumns._ID`, held as a string rather than a
  /// number. Combined with [type] and [volumeInfo] it identifies the file
  /// for as long as it stays in the library.
  final String id;

  /// The `content://` URI of the item, for example
  /// `content://media/external/images/media/42`.
  final String? uri;

  /// The display name of the file, including its extension, for example
  /// `'IMG_0001.jpg'`.
  ///
  /// Sourced from `MediaStore.MediaColumns.DISPLAY_NAME`. `null` when the
  /// row carries no name.
  final String? name;

  /// The MIME type of the file, for example `'image/jpeg'`.
  ///
  /// Sourced from `MediaStore.MediaColumns.MIME_TYPE`. `null` when
  /// `MediaStore` has not determined one for the file.
  final String? mimeType;

  /// The size of the file in bytes, for example `2048`.
  ///
  /// Sourced from `MediaStore.MediaColumns.SIZE`. `null` when the row
  /// reports no size.
  final int? sizeInBytes;

  /// When the item entered the media library, in milliseconds since the
  /// Unix epoch.
  ///
  /// Converted from `MediaStore.MediaColumns.DATE_ADDED`, which is
  /// expressed in seconds. `null` when the row carries no value.
  final int? dateAddedInMillis;

  /// When the file was last modified, in milliseconds since the Unix epoch.
  ///
  /// Converted from `MediaStore.MediaColumns.DATE_MODIFIED`, which is
  /// expressed in seconds. `null` when the row carries no value.
  final int? dateModifiedInMillis;

  /// When the item was captured, in milliseconds since the Unix epoch.
  ///
  /// Sourced from `MediaStore.MediaColumns.DATE_TAKEN`, which is already
  /// expressed in milliseconds, so no conversion happens here. `null` below
  /// API level 29 (Q), and `null` when the file has no recorded capture
  /// time.
  final int? dateTakenInMillis;

  /// The storage volume the file sits on.
  ///
  /// Null when the volume cannot be resolved.
  final VolumeInfo? volumeInfo;

  /// The path of the directory containing the file, relative to the root
  /// of its storage volume, for example `'DCIM/Camera/'`.
  ///
  /// Possible values:
  /// - When the file sits directly in the volume root, it is an empty string.
  /// - When not within the volume root, it always ends with a path separator.
  /// - `null` when the path cannot be resolved.
  final String? relativePath;

  /// The package name of the app that owns the item, for example
  /// `'com.android.camera'`.
  ///
  /// Sourced from `MediaStore.MediaColumns.OWNER_PACKAGE_NAME`. `null`
  /// below API level 29 (Q), and `null` when the item is not owned by any
  /// app.
  final String? ownerPackageName;

  /// Whether the item is still being written and not ready to be opened.
  ///
  /// Sourced from `MediaStore.MediaColumns.IS_PENDING`. `null` below API
  /// level 29 (Q).
  final bool? isPending;

  /// Whether the item has been moved to the trash and is therefore no
  /// longer visible in the collection it was queried from.
  ///
  /// Sourced from `MediaStore.MediaColumns.IS_TRASHED`. `null` below API
  /// level 30 (R).
  final bool? isTrashed;

  /// Whether the item is marked as a favorite.
  ///
  /// Sourced from `MediaStore.MediaColumns.IS_FAVORITE`. `null` below API
  /// level 30 (R).
  final bool? isFavorite;

  /// Whether the item belongs to the Downloads collection.
  ///
  /// Sourced from `MediaStore.MediaColumns.IS_DOWNLOAD`. `null` below API
  /// level 30 (R).
  final bool? isDownloaded;

  const MediaItem({
    required this.type,
    required this.id,
    required this.uri,
    required this.name,
    required this.mimeType,
    required this.sizeInBytes,
    required this.dateAddedInMillis,
    required this.dateModifiedInMillis,
    required this.dateTakenInMillis,
    required this.volumeInfo,
    required this.relativePath,
    required this.ownerPackageName,
    required this.isPending,
    required this.isTrashed,
    required this.isFavorite,
    required this.isDownloaded,
  });

  Map<String, dynamic> toJson() => _$MediaItemToJson(this);

  factory MediaItem.fromJson(Map<String, dynamic> json) =>
      _$MediaItemFromJson(json);

  @override
  List<Object?> get props => [
    type,
    id,
    uri,
    name,
    mimeType,
    sizeInBytes,
    dateAddedInMillis,
    dateModifiedInMillis,
    dateTakenInMillis,
    volumeInfo,
    relativePath,
    ownerPackageName,
    isPending,
    isTrashed,
    isFavorite,
    isDownloaded,
  ];
}
