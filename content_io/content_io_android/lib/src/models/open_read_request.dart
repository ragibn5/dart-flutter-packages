import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'open_read_request.g.dart';

@immutable
@JsonSerializable()
class OpenReadRequest extends Equatable {
  /// The `content://` URI of the content to read.
  ///
  /// For example `content://media/external/images/media/42`.
  final String uri;

  /// The absolute filesystem path of the content, if known.
  ///
  /// Note:
  /// - Not all content is backed by a file the app can name, such as a
  ///   document from a cloud provider, so this is often `null`.
  /// - When the app can read the file at this path, it's read directly,
  ///   with no platform session. Otherwise, or without it, the content is
  ///   opened through [uri].
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? filePath;

  const OpenReadRequest({required this.uri, this.filePath});

  @override
  List<Object?> get props => [uri, filePath];

  Map<String, dynamic> toJson() => _$OpenReadRequestToJson(this);

  factory OpenReadRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenReadRequestFromJson(json);
}
