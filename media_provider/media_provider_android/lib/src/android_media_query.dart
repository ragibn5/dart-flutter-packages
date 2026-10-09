import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:media_provider_android/src/android_media_type.dart';
import 'package:media_provider_android/src/android_storage_volume_spec.dart';
import 'package:meta/meta.dart';

part 'android_media_query.g.dart';

@immutable
@JsonSerializable()
class AndroidMediaQuery extends Equatable {
  /// The media types to include in the query result.
  final Set<AndroidMediaType> types;

  /// The storage volumes to search.
  final Set<AndroidStorageVolumeSpec> volumes;

  const AndroidMediaQuery({required this.types, required this.volumes});

  @override
  List<Object?> get props => [types, volumes];

  Map<String, dynamic> toJson() => _$AndroidMediaQueryToJson(this);

  factory AndroidMediaQuery.fromJson(Map<String, dynamic> json) =>
      _$AndroidMediaQueryFromJson(json);

  AndroidMediaQuery copyWith({
    Set<AndroidMediaType>? types,
    Set<AndroidStorageVolumeSpec>? volumes,
  }) {
    return AndroidMediaQuery(
      types: types ?? this.types,
      volumes: volumes ?? this.volumes,
    );
  }
}
