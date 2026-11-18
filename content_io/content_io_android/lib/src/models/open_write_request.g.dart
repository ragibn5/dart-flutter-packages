// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_write_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenWriteRequest _$OpenWriteRequestFromJson(Map<String, dynamic> json) =>
    OpenWriteRequest(
      uri: json['uri'] as String,
      mode:
          $enumDecodeNullable(_$WriteModeEnumMap, json['mode']) ??
          WriteMode.truncate,
    );

Map<String, dynamic> _$OpenWriteRequestToJson(OpenWriteRequest instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'mode': _$WriteModeEnumMap[instance.mode]!,
    };

const _$WriteModeEnumMap = {
  WriteMode.truncate: 'truncate',
  WriteMode.append: 'append',
};
