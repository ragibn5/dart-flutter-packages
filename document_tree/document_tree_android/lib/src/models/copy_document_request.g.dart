// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'copy_document_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CopyDocumentRequest _$CopyDocumentRequestFromJson(Map<String, dynamic> json) =>
    CopyDocumentRequest(
      sourceUri: json['sourceUri'] as String,
      treeUri: json['treeUri'] as String,
      path: json['path'] as String,
      mimeType: json['mimeType'] as String?,
      overwrite: json['overwrite'] as bool? ?? false,
    );

Map<String, dynamic> _$CopyDocumentRequestToJson(
  CopyDocumentRequest instance,
) => <String, dynamic>{
  'sourceUri': instance.sourceUri,
  'treeUri': instance.treeUri,
  'path': instance.path,
  'mimeType': instance.mimeType,
  'overwrite': instance.overwrite,
};
