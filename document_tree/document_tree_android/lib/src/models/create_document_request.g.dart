// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_document_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateDocumentRequest _$CreateDocumentRequestFromJson(
  Map<String, dynamic> json,
) => CreateDocumentRequest(
  treeUri: json['treeUri'] as String,
  path: json['path'] as String,
  mimeType: json['mimeType'] as String?,
);

Map<String, dynamic> _$CreateDocumentRequestToJson(
  CreateDocumentRequest instance,
) => <String, dynamic>{
  'treeUri': instance.treeUri,
  'path': instance.path,
  'mimeType': instance.mimeType,
};
