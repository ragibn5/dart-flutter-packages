import 'package:content_io_android/src/models/thumbnail_size.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'open_thumbnail_read_request.g.dart';

/// A request to read the thumbnail of the content behind a URI.
///
/// Note:
/// - The content's provider, such as `MediaStore`, is asked for its thumbnail
///   first; the first read of one may be slower, while it's generated.
/// - A provider's thumbnail that already fits the request is read as it is,
///   never the original content's bytes.
/// - When the provider has none, or gives the content itself (as a document
///   provider does for a video, or an image without an embedded thumbnail),
///   the thumbnail is made from the content: a frame of a video, or the image
///   decoded scaled down. That reads the content.
@immutable
@JsonSerializable()
class OpenThumbnailReadRequest extends Equatable {
  /// The `content://` URI of the content whose thumbnail to read.
  ///
  /// For example `content://media/external/images/media/42`.
  final String uri;

  /// The size to request the thumbnail at.
  final ThumbnailSize size;

  /// Whether a thumbnail much larger than [size] is scaled down to close to
  /// it, as Android's `ContentResolver.loadThumbnail` does: by the larger of
  /// the width and height ratios, in whole numbers. The longer side stays at
  /// least the requested size.
  final bool scaleDownToSize;

  /// Whether a thumbnail meant to be shown rotated is rotated upright: by its
  /// provider's hint, else by a HEIF image's container rotation or any other
  /// image's EXIF orientation.
  ///
  /// Note: Mirroring isn't applied, as Android doesn't report it; a mirrored
  /// HEIF image, such as a front-camera photo from an iPhone, may show turned.
  final bool rotateUpright;

  /// Creates a thumbnail read request.
  ///
  /// Parameters:
  /// - [uri]: the `content://` URI of the content whose thumbnail to read.
  /// - [size]: the size to request the thumbnail at.
  /// - [scaleDownToSize]: whether a much larger thumbnail is scaled down to
  ///   close to [size].
  /// - [rotateUpright]: whether a thumbnail meant to be shown rotated is
  ///   rotated upright.
  const OpenThumbnailReadRequest({
    required this.uri,
    required this.size,
    this.scaleDownToSize = true,
    this.rotateUpright = true,
  });

  @override
  List<Object?> get props => [uri, size, scaleDownToSize, rotateUpright];

  Map<String, dynamic> toJson() => _$OpenThumbnailReadRequestToJson(this);

  factory OpenThumbnailReadRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenThumbnailReadRequestFromJson(json);
}
