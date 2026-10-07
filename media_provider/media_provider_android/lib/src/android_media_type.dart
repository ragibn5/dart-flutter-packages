import 'package:json_annotation/json_annotation.dart';

/// The kind of media an item is.
///
/// Matches the `MediaStore` collection the item is read from.
@JsonEnum()
enum AndroidMediaType {
  /// An image, read from the images collection.
  @JsonValue('PHOTO')
  photo,

  /// A video, read from the videos collection.
  @JsonValue('VIDEO')
  video,
}
