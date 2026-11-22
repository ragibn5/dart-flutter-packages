import 'package:content_io_android/src/models/content_hash_algorithm.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'hash_content_request.g.dart';

@immutable
@JsonSerializable()
class HashContentRequest extends Equatable {
  /// The `content://` URI of the content to hash.
  ///
  /// For example `content://media/external/images/media/42`.
  final String uri;

  /// The algorithm to hash it with.
  final ContentHashAlgorithm algorithm;

  const HashContentRequest({
    required this.uri,
    this.algorithm = ContentHashAlgorithm.sha256,
  });

  @override
  List<Object?> get props => [uri, algorithm];

  Map<String, dynamic> toJson() => _$HashContentRequestToJson(this);

  factory HashContentRequest.fromJson(Map<String, dynamic> json) =>
      _$HashContentRequestFromJson(json);
}
