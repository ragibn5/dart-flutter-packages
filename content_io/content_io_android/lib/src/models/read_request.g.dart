// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'read_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadRequest _$ReadRequestFromJson(Map<String, dynamic> json) => ReadRequest(
  sessionId: json['sessionId'] as String,
  start: (json['start'] as num).toInt(),
  length: (json['length'] as num).toInt(),
);

Map<String, dynamic> _$ReadRequestToJson(ReadRequest instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'start': instance.start,
      'length': instance.length,
    };
