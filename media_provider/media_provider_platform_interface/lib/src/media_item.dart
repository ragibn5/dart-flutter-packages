import 'package:meta/meta.dart';

/// A media file (photo, video, ...) on the device.
@immutable
class MediaItem {
  /// Platform identifier of the item.
  ///
  /// Android: the `MediaStore` row ID, unique within its collection.
  final String id;

  /// File name, including extension.
  final String name;

  /// MIME type, e.g. `image/jpeg`.
  final String mimeType;

  /// File size in bytes.
  final int sizeInBytes;

  /// When the item was added to the device's media library, in milliseconds
  /// since epoch.
  final int dateAddedInMillis;

  /// When the file was last modified, in milliseconds since epoch.
  final int dateModifiedInMillis;

  /// When the media was captured (usually from EXIF), in milliseconds since
  /// epoch.
  ///
  /// `null` if unknown.
  final int? dateTakenInMillis;

  /// Platform URI for opening the item.
  ///
  /// Android: a `content://` URI.
  final String uri;

  /// Directory relative to the storage volume root, e.g. `DCIM/Camera/`.
  ///
  /// `null` if unsupported by the device (Android: below API 29).
  final String? relativePath;

  /// Width in pixels.
  ///
  /// `null` if unknown.
  final int? width;

  /// Height in pixels.
  ///
  /// `null` if unknown.
  final int? height;

  /// Playback duration in milliseconds, for video and audio.
  ///
  /// `null` for images.
  final int? durationInMillis;

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
    required this.id,
    required this.name,
    required this.mimeType,
    required this.sizeInBytes,
    required this.dateAddedInMillis,
    required this.dateModifiedInMillis,
    required this.dateTakenInMillis,
    required this.uri,
    required this.relativePath,
    required this.width,
    required this.height,
    required this.durationInMillis,
    required this.isPending,
    required this.isTrashed,
    required this.isFavorite,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mimeType': mimeType,
      'sizeInBytes': sizeInBytes,
      'dateAddedInMillis': dateAddedInMillis,
      'dateModifiedInMillis': dateModifiedInMillis,
      'dateTakenInMillis': dateTakenInMillis,
      'uri': uri,
      'relativePath': relativePath,
      'width': width,
      'height': height,
      'durationInMillis': durationInMillis,
      'isPending': isPending,
      'isTrashed': isTrashed,
      'isFavorite': isFavorite,
    };
  }

  factory MediaItem.fromMap(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'] as String,
      name: json['name'] as String,
      mimeType: json['mimeType'] as String,
      sizeInBytes: json['sizeInBytes'] as int,
      dateAddedInMillis: json['dateAddedInMillis'] as int,
      dateModifiedInMillis: json['dateModifiedInMillis'] as int,
      dateTakenInMillis: json['dateTakenInMillis'] as int?,
      uri: json['uri'] as String,
      relativePath: json['relativePath'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      durationInMillis: json['durationInMillis'] as int?,
      isPending: json['isPending'] as bool?,
      isTrashed: json['isTrashed'] as bool?,
      isFavorite: json['isFavorite'] as bool?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          mimeType == other.mimeType &&
          sizeInBytes == other.sizeInBytes &&
          dateAddedInMillis == other.dateAddedInMillis &&
          dateModifiedInMillis == other.dateModifiedInMillis &&
          dateTakenInMillis == other.dateTakenInMillis &&
          uri == other.uri &&
          relativePath == other.relativePath &&
          width == other.width &&
          height == other.height &&
          durationInMillis == other.durationInMillis &&
          isPending == other.isPending &&
          isTrashed == other.isTrashed &&
          isFavorite == other.isFavorite;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    mimeType,
    sizeInBytes,
    dateAddedInMillis,
    dateModifiedInMillis,
    dateTakenInMillis,
    uri,
    relativePath,
    width,
    height,
    durationInMillis,
    isPending,
    isTrashed,
    isFavorite,
  );

  @override
  String toString() {
    return [
      'MediaItem {',
      ' id: $id,',
      ' name: $name,',
      ' mimeType: $mimeType,',
      ' sizeInBytes: $sizeInBytes,',
      ' dateAddedInMillis: $dateAddedInMillis,',
      ' dateModifiedInMillis: $dateModifiedInMillis,',
      ' dateTakenInMillis: $dateTakenInMillis,',
      ' uri: $uri,',
      ' relativePath: $relativePath,',
      ' width: $width,',
      ' height: $height,',
      ' durationInMillis: $durationInMillis,',
      ' isPending: $isPending,',
      ' isTrashed: $isTrashed,',
      ' isFavorite: $isFavorite',
      '}',
    ].join('\n');
  }
}
