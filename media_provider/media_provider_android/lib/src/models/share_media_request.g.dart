// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_media_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShareMediaRequest _$ShareMediaRequestFromJson(Map<String, dynamic> json) =>
    ShareMediaRequest(
      contentUris: (json['contentUris'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      chooserTitle: json['chooserTitle'] as String?,
    );

Map<String, dynamic> _$ShareMediaRequestToJson(ShareMediaRequest instance) =>
    <String, dynamic>{
      'contentUris': instance.contentUris,
      'chooserTitle': instance.chooserTitle,
    };
