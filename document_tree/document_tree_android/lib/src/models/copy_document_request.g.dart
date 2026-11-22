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
      parentUri: json['parentUri'] as String?,
      mimeType: json['mimeType'] as String?,
      hashAlgorithm: $enumDecodeNullable(
        _$ContentHashAlgorithmEnumMap,
        json['hashAlgorithm'],
      ),
    );

Map<String, dynamic> _$CopyDocumentRequestToJson(
  CopyDocumentRequest instance,
) => <String, dynamic>{
  'sourceUri': instance.sourceUri,
  'treeUri': instance.treeUri,
  'path': instance.path,
  'parentUri': instance.parentUri,
  'mimeType': instance.mimeType,
  'hashAlgorithm': _$ContentHashAlgorithmEnumMap[instance.hashAlgorithm],
};

const _$ContentHashAlgorithmEnumMap = {ContentHashAlgorithm.sha256: 'sha256'};
