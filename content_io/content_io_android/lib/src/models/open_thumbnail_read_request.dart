import 'package:content_io_android/src/models/thumbnail_size.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'open_thumbnail_read_request.g.dart';

/// A request to read the thumbnail of the content behind a URI.
///
/// Note:
/// - Only the thumbnail's bytes are read, never the original content's.
/// - Thumbnails are generated and cached by the content's provider, such as
///   `MediaStore`; the first read of one may be slower, while it's generated.
@immutable
@JsonSerializable()
class OpenThumbnailReadRequest extends Equatable {
  /// The `content://` URI of the content whose thumbnail to read.
  ///
  /// For example `content://media/external/images/media/42`.
  final String uri;

  /// The size to request the thumbnail at.
  final ThumbnailSize size;

  const OpenThumbnailReadRequest({required this.uri, required this.size});

  @override
  List<Object?> get props => [uri, size];

  Map<String, dynamic> toJson() => _$OpenThumbnailReadRequestToJson(this);

  factory OpenThumbnailReadRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenThumbnailReadRequestFromJson(json);
}
