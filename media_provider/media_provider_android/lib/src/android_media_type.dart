import 'package:json_annotation/json_annotation.dart';

part 'android_media_type.g.dart';

/// The kind of media an item is.
///
/// Matches the `MediaStore` collection the item is read from.
@JsonEnum(alwaysCreate: true)
enum AndroidMediaType {
  /// An image, read from the images collection.
  @JsonValue('PHOTO')
  photo,

  /// A video, read from the videos collection.
  @JsonValue('VIDEO')
  video,
}

/// The wire name of a media type.
extension AndroidMediaTypeJsonValue on AndroidMediaType {
  /// The name used on the method channel, for example `'PHOTO'`.
  String get jsonValue => _$AndroidMediaTypeEnumMap[this]!;
}
