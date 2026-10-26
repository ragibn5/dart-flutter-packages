// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_media_with_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenMediaWithRequest _$OpenMediaWithRequestFromJson(
  Map<String, dynamic> json,
) => OpenMediaWithRequest(
  contentUri: json['contentUri'] as String,
  chooserTitle: json['chooserTitle'] as String?,
);

Map<String, dynamic> _$OpenMediaWithRequestToJson(
  OpenMediaWithRequest instance,
) => <String, dynamic>{
  'contentUri': instance.contentUri,
  'chooserTitle': instance.chooserTitle,
};
