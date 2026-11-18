// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_directory_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateDirectoryRequest _$CreateDirectoryRequestFromJson(
  Map<String, dynamic> json,
) => CreateDirectoryRequest(
  treeUri: json['treeUri'] as String,
  path: json['path'] as String,
);

Map<String, dynamic> _$CreateDirectoryRequestToJson(
  CreateDirectoryRequest instance,
) => <String, dynamic>{'treeUri': instance.treeUri, 'path': instance.path};
