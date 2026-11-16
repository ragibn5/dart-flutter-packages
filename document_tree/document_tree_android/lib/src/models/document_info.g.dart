// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentInfo _$DocumentInfoFromJson(Map<String, dynamic> json) => DocumentInfo(
  uri: json['uri'] as String,
  path: json['path'] as String,
  displayName: json['displayName'] as String,
  isDirectory: json['isDirectory'] as bool,
  canWrite: json['canWrite'] as bool,
  mimeType: json['mimeType'] as String,
  sizeInBytes: (json['sizeInBytes'] as num?)?.toInt(),
  lastModifiedInMillis: (json['lastModifiedInMillis'] as num?)?.toInt(),
);

Map<String, dynamic> _$DocumentInfoToJson(DocumentInfo instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'path': instance.path,
      'displayName': instance.displayName,
      'isDirectory': instance.isDirectory,
      'canWrite': instance.canWrite,
      'mimeType': instance.mimeType,
      'sizeInBytes': instance.sizeInBytes,
      'lastModifiedInMillis': instance.lastModifiedInMillis,
    };
