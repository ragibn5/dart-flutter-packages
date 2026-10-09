// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'android_media_query.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AndroidMediaQuery _$AndroidMediaQueryFromJson(Map<String, dynamic> json) =>
    AndroidMediaQuery(
      types: (json['types'] as List<dynamic>)
          .map((e) => $enumDecode(_$AndroidMediaTypeEnumMap, e))
          .toSet(),
      volumes: (json['volumes'] as List<dynamic>)
          .map(
            (e) => AndroidStorageVolumeSpec.fromJson(e as Map<String, dynamic>),
          )
          .toSet(),
    );

Map<String, dynamic> _$AndroidMediaQueryToJson(
  AndroidMediaQuery instance,
) => <String, dynamic>{
  'types': instance.types.map((e) => _$AndroidMediaTypeEnumMap[e]!).toList(),
  'volumes': instance.volumes.toList(),
};

const _$AndroidMediaTypeEnumMap = {
  AndroidMediaType.photo: 'PHOTO',
  AndroidMediaType.video: 'VIDEO',
};
