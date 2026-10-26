import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:media_provider_android/src/models/media_item.dart';
import 'package:media_provider_android/src/models/thumbnail_size.dart';
import 'package:meta/meta.dart';

part 'open_thumbnail_read_request.g.dart';

/// A request to read the thumbnail of a `MediaStore` item.
///
/// Note:
/// - Only the thumbnail's bytes are read, never the original item's.
/// - Thumbnails are generated and cached by `MediaStore`; the first read of
///   one may be slower, while it's generated.
@immutable
@JsonSerializable()
class OpenThumbnailReadRequest extends Equatable {
  /// The `content://` URI of the item whose thumbnail to read.
  ///
  /// For example `content://media/external/images/media/42`.
  final String contentUri;

  /// The size to request the thumbnail at.
  final ThumbnailSize size;

  const OpenThumbnailReadRequest({
    required this.contentUri,
    required this.size,
  });

  /// A request for the thumbnail of [item].
  ///
  /// Parameters:
  /// - [item]: the item whose thumbnail to read.
  /// - [size]: the size to request the thumbnail at.
  factory OpenThumbnailReadRequest.fromItem(
    MediaItem item, {
    required ThumbnailSize size,
  }) {
    return OpenThumbnailReadRequest(contentUri: item.uri, size: size);
  }

  @override
  List<Object?> get props => [contentUri, size];

  Map<String, dynamic> toJson() => _$OpenThumbnailReadRequestToJson(this);

  factory OpenThumbnailReadRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenThumbnailReadRequestFromJson(json);
}
