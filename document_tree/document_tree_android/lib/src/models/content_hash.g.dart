// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_hash.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContentHash _$ContentHashFromJson(Map<String, dynamic> json) => ContentHash(
  algorithm: $enumDecode(_$ContentHashAlgorithmEnumMap, json['algorithm']),
  value: json['value'] as String,
);

Map<String, dynamic> _$ContentHashToJson(ContentHash instance) =>
    <String, dynamic>{
      'algorithm': _$ContentHashAlgorithmEnumMap[instance.algorithm]!,
      'value': instance.value,
    };

const _$ContentHashAlgorithmEnumMap = {ContentHashAlgorithm.sha256: 'sha256'};
