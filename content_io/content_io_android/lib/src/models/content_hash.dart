import 'package:content_io_android/src/models/content_hash_algorithm.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'content_hash.g.dart';

/// The hash of some content: equal hashes of one algorithm mean equal content.
@immutable
@JsonSerializable()
class ContentHash extends Equatable {
  /// The algorithm it's made with.
  final ContentHashAlgorithm algorithm;

  /// The hash, in lowercase hexadecimal.
  final String value;

  const ContentHash({required this.algorithm, required this.value});

  @override
  List<Object?> get props => [algorithm, value];

  Map<String, dynamic> toJson() => _$ContentHashToJson(this);

  factory ContentHash.fromJson(Map<String, dynamic> json) =>
      _$ContentHashFromJson(json);
}
