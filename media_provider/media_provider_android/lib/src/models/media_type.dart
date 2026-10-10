import 'package:json_annotation/json_annotation.dart';

part 'media_type.g.dart';

/// The kind of media an item is.
///
/// Matches the `MediaStore` collection the item is read from.
@JsonEnum(alwaysCreate: true)
enum MediaType {
  /// An image, read from the images collection.
  @JsonValue('PHOTO')
  photo,

  /// A video, read from the videos collection.
  @JsonValue('VIDEO')
  video,
}
