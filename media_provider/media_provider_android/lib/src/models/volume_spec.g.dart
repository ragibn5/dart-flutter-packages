// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'volume_spec.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExternalVolumeSpec _$ExternalVolumeSpecFromJson(Map<String, dynamic> json) =>
    ExternalVolumeSpec(
      uuid: json['uuid'] as String,
      relativePathScope: json['relativePathScope'] as String? ?? '',
    );

Map<String, dynamic> _$ExternalVolumeSpecToJson(ExternalVolumeSpec instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'relativePathScope': instance.relativePathScope,
    };
