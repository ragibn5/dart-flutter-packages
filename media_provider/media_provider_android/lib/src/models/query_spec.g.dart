// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'query_spec.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuerySpec _$QuerySpecFromJson(Map<String, dynamic> json) => QuerySpec(
  types: (json['types'] as List<dynamic>)
      .map((e) => $enumDecode(_$MediaTypeEnumMap, e))
      .toSet(),
  volumes: (json['volumes'] as List<dynamic>)
      .map((e) => VolumeSpec.fromJson(e as Map<String, dynamic>))
      .toSet(),
);

Map<String, dynamic> _$QuerySpecToJson(QuerySpec instance) => <String, dynamic>{
  'types': instance.types.map((e) => _$MediaTypeEnumMap[e]!).toList(),
  'volumes': instance.volumes.toList(),
};

const _$MediaTypeEnumMap = {MediaType.photo: 'PHOTO', MediaType.video: 'VIDEO'};
