// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hash_content_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HashContentRequest _$HashContentRequestFromJson(Map<String, dynamic> json) =>
    HashContentRequest(
      uri: json['uri'] as String,
      algorithm:
          $enumDecodeNullable(
            _$ContentHashAlgorithmEnumMap,
            json['algorithm'],
          ) ??
          ContentHashAlgorithm.sha256,
    );

Map<String, dynamic> _$HashContentRequestToJson(HashContentRequest instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'algorithm': _$ContentHashAlgorithmEnumMap[instance.algorithm]!,
    };

const _$ContentHashAlgorithmEnumMap = {ContentHashAlgorithm.sha256: 'sha256'};
