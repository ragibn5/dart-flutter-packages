// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'copied_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CopiedDocument _$CopiedDocumentFromJson(Map<String, dynamic> json) =>
    CopiedDocument(
      document: DocumentInfo.fromJson(json['document'] as Map<String, dynamic>),
      contentHash: json['contentHash'] == null
          ? null
          : ContentHash.fromJson(json['contentHash'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CopiedDocumentToJson(CopiedDocument instance) =>
    <String, dynamic>{
      'document': instance.document.toJson(),
      'contentHash': instance.contentHash?.toJson(),
    };
