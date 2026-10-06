/// The kind of media an item is.
///
/// Matches the `MediaStore` collection the item is read from.
enum AndroidMediaType {
  /// An image, read from the images collection.
  photo,

  /// A video, read from the videos collection.
  video,
}
