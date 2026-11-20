// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_document_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetDocumentRequest _$GetDocumentRequestFromJson(Map<String, dynamic> json) =>
    GetDocumentRequest(
      treeUri: json['treeUri'] as String,
      path: json['path'] as String,
      parentUri: json['parentUri'] as String?,
    );

Map<String, dynamic> _$GetDocumentRequestToJson(GetDocumentRequest instance) =>
    <String, dynamic>{
      'treeUri': instance.treeUri,
      'path': instance.path,
      'parentUri': instance.parentUri,
    };
