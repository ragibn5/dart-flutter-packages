// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_document_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteDocumentRequest _$DeleteDocumentRequestFromJson(
  Map<String, dynamic> json,
) => DeleteDocumentRequest(
  treeUri: json['treeUri'] as String,
  path: json['path'] as String,
);

Map<String, dynamic> _$DeleteDocumentRequestToJson(
  DeleteDocumentRequest instance,
) => <String, dynamic>{'treeUri': instance.treeUri, 'path': instance.path};
