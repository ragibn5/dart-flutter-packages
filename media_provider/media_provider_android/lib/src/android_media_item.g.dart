// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'android_media_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AndroidMediaItem _$AndroidMediaItemFromJson(Map<String, dynamic> json) =>
    AndroidMediaItem(
      type: $enumDecode(_$AndroidMediaTypeEnumMap, json['type']),
      id: json['id'] as String,
      uri: json['uri'] as String?,
      name: json['name'] as String?,
      mimeType: json['mimeType'] as String?,
      sizeInBytes: (json['sizeInBytes'] as num?)?.toInt(),
      dateAddedInMillis: (json['dateAddedInMillis'] as num?)?.toInt(),
      dateModifiedInMillis: (json['dateModifiedInMillis'] as num?)?.toInt(),
      dateTakenInMillis: (json['dateTakenInMillis'] as num?)?.toInt(),
      volumeName: json['volumeName'] as String?,
      relativePath: json['relativePath'] as String?,
      ownerPackageName: json['ownerPackageName'] as String?,
      isPending: json['isPending'] as bool?,
      isTrashed: json['isTrashed'] as bool?,
      isFavorite: json['isFavorite'] as bool?,
      isDownloaded: json['isDownloaded'] as bool?,
    );

Map<String, dynamic> _$AndroidMediaItemToJson(AndroidMediaItem instance) =>
    <String, dynamic>{
      'type': _$AndroidMediaTypeEnumMap[instance.type]!,
      'id': instance.id,
      'uri': instance.uri,
      'name': instance.name,
      'mimeType': instance.mimeType,
      'sizeInBytes': instance.sizeInBytes,
      'dateAddedInMillis': instance.dateAddedInMillis,
      'dateModifiedInMillis': instance.dateModifiedInMillis,
      'dateTakenInMillis': instance.dateTakenInMillis,
      'volumeName': instance.volumeName,
      'relativePath': instance.relativePath,
      'ownerPackageName': instance.ownerPackageName,
      'isPending': instance.isPending,
      'isTrashed': instance.isTrashed,
      'isFavorite': instance.isFavorite,
      'isDownloaded': instance.isDownloaded,
    };

const _$AndroidMediaTypeEnumMap = {
  AndroidMediaType.photo: 'PHOTO',
  AndroidMediaType.video: 'VIDEO',
};
