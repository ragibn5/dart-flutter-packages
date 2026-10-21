import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'media_read_request.g.dart';

@immutable
@JsonSerializable()
class MediaReadRequest extends Equatable {
  /// The `content://` URI of an existing `MediaStore` item.
  ///
  /// For example `content://media/external/images/media/42`.
  final String contentUri;

  const MediaReadRequest({required this.contentUri});

  @override
  List<Object?> get props => [contentUri];

  Map<String, dynamic> toJson() => _$MediaReadRequestToJson(this);

  factory MediaReadRequest.fromJson(Map<String, dynamic> json) =>
      _$MediaReadRequestFromJson(json);
}
