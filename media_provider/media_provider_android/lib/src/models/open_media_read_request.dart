import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'open_media_read_request.g.dart';

@immutable
@JsonSerializable()
class OpenMediaReadRequest extends Equatable {
  /// The `content://` URI of an existing `MediaStore` item.
  ///
  /// For example `content://media/external/images/media/42`.
  final String contentUri;

  const OpenMediaReadRequest({required this.contentUri});

  @override
  List<Object?> get props => [contentUri];

  Map<String, dynamic> toJson() => _$OpenMediaReadRequestToJson(this);

  factory OpenMediaReadRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenMediaReadRequestFromJson(json);
}
