// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_documents_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListDocumentsRequest _$ListDocumentsRequestFromJson(
  Map<String, dynamic> json,
) => ListDocumentsRequest(
  treeUri: json['treeUri'] as String,
  path: json['path'] as String? ?? '',
  recursive: json['recursive'] as bool? ?? false,
);

Map<String, dynamic> _$ListDocumentsRequestToJson(
  ListDocumentsRequest instance,
) => <String, dynamic>{
  'treeUri': instance.treeUri,
  'path': instance.path,
  'recursive': instance.recursive,
};
