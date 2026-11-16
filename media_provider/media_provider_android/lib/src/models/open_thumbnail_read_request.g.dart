// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_thumbnail_read_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenThumbnailReadRequest _$OpenThumbnailReadRequestFromJson(
  Map<String, dynamic> json,
) => OpenThumbnailReadRequest(
  contentUri: json['contentUri'] as String,
  size: ThumbnailSize.fromJson(json['size'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OpenThumbnailReadRequestToJson(
  OpenThumbnailReadRequest instance,
) => <String, dynamic>{
  'contentUri': instance.contentUri,
  'size': instance.size.toJson(),
};
