import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:media_provider_android/src/models/media_item.dart';
import 'package:meta/meta.dart';

part 'open_media_with_request.g.dart';

/// A request to open a `MediaStore` item in another app.
///
/// Note:
/// The app it's opened in gets read access to the item. Its MIME type is read
/// from `MediaStore`.
@immutable
@JsonSerializable()
class OpenMediaWithRequest extends Equatable {
  /// The `content://` URI of the item to open.
  ///
  /// For example `content://media/external/images/media/42`.
  final String contentUri;

  /// The title of the app chooser, or `null` for the system's default.
  final String? chooserTitle;

  const OpenMediaWithRequest({required this.contentUri, this.chooserTitle});

  /// A request to open [item].
  ///
  /// Parameters:
  /// - [item]: the item to open.
  /// - [chooserTitle]: the title of the app chooser, or `null` for the
  ///   system's default.
  factory OpenMediaWithRequest.fromItem(
    MediaItem item, {
    String? chooserTitle,
  }) {
    return OpenMediaWithRequest(
      contentUri: item.uri,
      chooserTitle: chooserTitle,
    );
  }

  @override
  List<Object?> get props => [contentUri, chooserTitle];

  Map<String, dynamic> toJson() => _$OpenMediaWithRequestToJson(this);

  factory OpenMediaWithRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenMediaWithRequestFromJson(json);
}
