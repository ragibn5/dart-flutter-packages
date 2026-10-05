/// Converts between platform-interface models and the Android channel's wire
/// format.
///
/// Wire names must match the `@SerialName`s of the Kotlin `MediaType` enum.
library;

import 'package:media_provider_android/src/android_media_item.dart';
import 'package:media_provider_android/src/android_media_type.dart';

/// The wire name of [type].
String encodeMediaType(AndroidMediaType type) => switch (type) {
  AndroidMediaType.photo => 'photo',
  AndroidMediaType.video => 'video',
};

/// The [AndroidMediaType] whose wire name is [name].
///
/// Throws a [FormatException] if [name] is unknown.
AndroidMediaType decodeMediaType(String name) =>
    AndroidMediaType.values.firstWhere(
      (type) => encodeMediaType(type) == name,
      orElse: () => throw FormatException('Unknown media type', name),
    );

/// Decodes a `MediaItemData` sent by the Kotlin side.
AndroidMediaItem decodeMediaItem(Map<String, dynamic> json) {
  return AndroidMediaItem(
    type: decodeMediaType(json['type'] as String),
    id: json['id'] as String,
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
