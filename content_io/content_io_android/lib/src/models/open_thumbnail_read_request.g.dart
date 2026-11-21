// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_thumbnail_read_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenThumbnailReadRequest _$OpenThumbnailReadRequestFromJson(
  Map<String, dynamic> json,
) => OpenThumbnailReadRequest(
  uri: json['uri'] as String,
  size: ThumbnailSize.fromJson(json['size'] as Map<String, dynamic>),
  scaleDownToSize: json['scaleDownToSize'] as bool? ?? true,
  rotateUpright: json['rotateUpright'] as bool? ?? true,
);

Map<String, dynamic> _$OpenThumbnailReadRequestToJson(
  OpenThumbnailReadRequest instance,
) => <String, dynamic>{
  'uri': instance.uri,
  'size': instance.size.toJson(),
  'scaleDownToSize': instance.scaleDownToSize,
  'rotateUpright': instance.rotateUpright,
};
