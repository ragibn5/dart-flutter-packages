// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_tree.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentTree _$DocumentTreeFromJson(Map<String, dynamic> json) => DocumentTree(
  uri: json['uri'] as String,
  displayName: json['displayName'] as String,
  canWrite: json['canWrite'] as bool,
  location: json['location'] == null
      ? null
      : TreeLocation.fromJson(json['location'] as Map<String, dynamic>),
  grantedAtInMillis: (json['grantedAtInMillis'] as num).toInt(),
  lastModifiedInMillis: (json['lastModifiedInMillis'] as num?)?.toInt(),
);

Map<String, dynamic> _$DocumentTreeToJson(DocumentTree instance) =>
    <String, dynamic>{
      'uri': instance.uri,
      'displayName': instance.displayName,
      'canWrite': instance.canWrite,
      'location': instance.location?.toJson(),
      'grantedAtInMillis': instance.grantedAtInMillis,
      'lastModifiedInMillis': instance.lastModifiedInMillis,
    };
