import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:media_provider_android/src/models/media_item.dart';
import 'package:meta/meta.dart';

part 'open_media_read_request.g.dart';

@immutable
@JsonSerializable()
class OpenMediaReadRequest extends Equatable {
  /// The `content://` URI of an existing `MediaStore` item.
  ///
  /// For example `content://media/external/images/media/42`.
  final String contentUri;

  /// The absolute filesystem path of the item, if available.
  ///
  /// Note:
  /// - Not all MediaStore returned items are backed by files,
  /// for those items, there is no backing file to begin with, so
  /// `filePath` will always be `null`.
  ///- When the app can read the file at this path, it's read directly,
  /// with no platform session. Otherwise, or, without it, the item is
  /// opened through [contentUri].
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? filePath;

  const OpenMediaReadRequest({required this.contentUri, this.filePath});

  /// A request for [item], with the hints it carries.
  factory OpenMediaReadRequest.fromItem(MediaItem item) {
    return OpenMediaReadRequest(
      contentUri: item.uri,
      filePath: item.fileLocation?.absoluteFilePath,
    );
  }

  @override
  List<Object?> get props => [contentUri, filePath];

  Map<String, dynamic> toJson() => _$OpenMediaReadRequestToJson(this);

  factory OpenMediaReadRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenMediaReadRequestFromJson(json);
}
