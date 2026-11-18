// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rename_document_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RenameDocumentRequest _$RenameDocumentRequestFromJson(
  Map<String, dynamic> json,
) => RenameDocumentRequest(
  treeUri: json['treeUri'] as String,
  path: json['path'] as String,
  newName: json['newName'] as String,
);

Map<String, dynamic> _$RenameDocumentRequestToJson(
  RenameDocumentRequest instance,
) => <String, dynamic>{
  'treeUri': instance.treeUri,
  'path': instance.path,
  'newName': instance.newName,
};
