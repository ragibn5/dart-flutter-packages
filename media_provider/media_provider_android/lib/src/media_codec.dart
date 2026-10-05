/// Converts between platform-interface models and the Android channel's wire
/// format.
///
/// Wire names must match the `@SerialName`s of the Kotlin `MediaType` enum.
library;

import 'dart:io';

import 'package:media_provider_platform_interface/media_provider_platform_interface.dart';

/// The wire name of [type].
String encodeMediaType(MediaType type) => switch (type) {
  MediaType.photo => 'photo',
  MediaType.video => 'video',
};

/// The [MediaType] whose wire name is [name].
///
/// Throws a [FormatException] if [name] is unknown.
MediaType decodeMediaType(String name) => MediaType.values.firstWhere(
  (type) => encodeMediaType(type) == name,
  orElse: () => throw FormatException('Unknown media type', name),
);

/// Decodes a `MediaItemData` sent by the Kotlin side.
MediaItem decodeMediaItem(Map<String, dynamic> json) {
  return MediaItem(
    type: decodeMediaType(json['type'] as String),
    id: json['id'] as String,
    osName: Platform.operatingSystem,
    uri: json['uri'] as String?,
    name: json['name'] as String?,
    mimeType: json['mimeType'] as String?,
    sizeInBytes: json['sizeInBytes'] as int?,
    dateAddedInMillis: json['dateAddedInMillis'] as int?,
    dateModifiedInMillis: json['dateModifiedInMillis'] as int?,
    volumeName: json['volumeName'] as String?,
    relativePath: json['relativePath'] as String?,
    isPending: json['isPending'] as bool?,
    isTrashed: json['isTrashed'] as bool?,
    isFavorite: json['isFavorite'] as bool?,
  );
}
