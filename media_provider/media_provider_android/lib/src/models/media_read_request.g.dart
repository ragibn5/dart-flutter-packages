// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_read_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaReadRequest _$MediaReadRequestFromJson(Map<String, dynamic> json) =>
    MediaReadRequest(
      sessionId: json['sessionId'] as String,
      start: (json['start'] as num).toInt(),
      length: (json['length'] as num).toInt(),
    );

Map<String, dynamic> _$MediaReadRequestToJson(MediaReadRequest instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'start': instance.start,
      'length': instance.length,
    };
