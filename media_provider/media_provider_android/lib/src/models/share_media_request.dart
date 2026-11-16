import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:media_provider_android/src/models/media_item.dart';
import 'package:meta/meta.dart';

part 'share_media_request.g.dart';

/// A request to share `MediaStore` items with another app.
///
/// Note:
/// The items are shared as they are, without copying; the app they're shared
/// with gets read access to them. Their MIME type is read from `MediaStore`.
@immutable
@JsonSerializable()
class ShareMediaRequest extends Equatable {
  /// The `content://` URIs of the items to share; at least one.
  ///
  /// For example `content://media/external/images/media/42`.
  final List<String> contentUris;

  /// The title of the share sheet, or `null` for the system's default.
  final String? chooserTitle;

  const ShareMediaRequest({required this.contentUris, this.chooserTitle})
    : assert(contentUris.length > 0, 'contentUris must not be empty');

  /// A request to share [items].
  ///
  /// Parameters:
  /// - [items]: the items to share; at least one.
  /// - [chooserTitle]: the title of the share sheet, or `null` for the
  ///   system's default.
  factory ShareMediaRequest.fromItems(
    List<MediaItem> items, {
    String? chooserTitle,
  }) {
    return ShareMediaRequest(
      contentUris: [for (final item in items) item.uri],
      chooserTitle: chooserTitle,
    );
  }

  @override
  List<Object?> get props => [contentUris, chooserTitle];

  Map<String, dynamic> toJson() => _$ShareMediaRequestToJson(this);

  factory ShareMediaRequest.fromJson(Map<String, dynamic> json) =>
      _$ShareMediaRequestFromJson(json);
}
