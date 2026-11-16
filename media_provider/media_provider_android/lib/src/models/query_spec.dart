import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:media_provider_android/src/models/media_type.dart';
import 'package:media_provider_android/src/models/volume_spec.dart';
import 'package:meta/meta.dart';

part 'query_spec.g.dart';

@immutable
@JsonSerializable()
class QuerySpec extends Equatable {
  /// The media types to include in the query result.
  final Set<MediaType> types;

  /// The storage volumes to search.
  final Set<VolumeSpec> volumes;

  const QuerySpec({required this.types, required this.volumes});

  @override
  List<Object?> get props => [types, volumes];

  Map<String, dynamic> toJson() => _$QuerySpecToJson(this);

  factory QuerySpec.fromJson(Map<String, dynamic> json) =>
      _$QuerySpecFromJson(json);

  QuerySpec copyWith({Set<MediaType>? types, Set<VolumeSpec>? volumes}) {
    return QuerySpec(
      types: types ?? this.types,
      volumes: volumes ?? this.volumes,
    );
  }
}
