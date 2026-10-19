// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_read_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaReadRequest _$MediaReadRequestFromJson(Map<String, dynamic> json) =>
    MediaReadRequest(
      uri: json['uri'] as String,
      requireOriginal: json['requireOriginal'] as bool? ?? false,
    );

Map<String, dynamic> _$MediaReadRequestToJson(MediaReadRequest instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'requireOriginal': instance.requireOriginal,
    };
