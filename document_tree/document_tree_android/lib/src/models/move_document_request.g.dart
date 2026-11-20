// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'move_document_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MoveDocumentRequest _$MoveDocumentRequestFromJson(Map<String, dynamic> json) =>
    MoveDocumentRequest(
      treeUri: json['treeUri'] as String,
      path: json['path'] as String,
      newParentPath: json['newParentPath'] as String,
      parentUri: json['parentUri'] as String?,
      newParentUri: json['newParentUri'] as String?,
    );

Map<String, dynamic> _$MoveDocumentRequestToJson(
  MoveDocumentRequest instance,
) => <String, dynamic>{
  'treeUri': instance.treeUri,
  'path': instance.path,
  'newParentPath': instance.newParentPath,
  'parentUri': instance.parentUri,
  'newParentUri': instance.newParentUri,
};
