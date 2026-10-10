// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaItem _$MediaItemFromJson(Map<String, dynamic> json) => MediaItem(
  type: $enumDecode(_$MediaTypeEnumMap, json['type']),
  id: json['id'] as String,
  uri: json['uri'] as String?,
  name: json['name'] as String?,
  mimeType: json['mimeType'] as String?,
  sizeInBytes: (json['sizeInBytes'] as num?)?.toInt(),
  dateAddedInMillis: (json['dateAddedInMillis'] as num?)?.toInt(),
  dateModifiedInMillis: (json['dateModifiedInMillis'] as num?)?.toInt(),
  dateTakenInMillis: (json['dateTakenInMillis'] as num?)?.toInt(),
  volumeInfo: json['volumeInfo'] == null
      ? null
      : VolumeInfo.fromJson(json['volumeInfo'] as Map<String, dynamic>),
  relativePath: json['relativePath'] as String?,
  ownerPackageName: json['ownerPackageName'] as String?,
  isPending: json['isPending'] as bool?,
  isTrashed: json['isTrashed'] as bool?,
  isFavorite: json['isFavorite'] as bool?,
  isDownloaded: json['isDownloaded'] as bool?,
);

Map<String, dynamic> _$MediaItemToJson(MediaItem instance) => <String, dynamic>{
  'type': _$MediaTypeEnumMap[instance.type]!,
  'id': instance.id,
  'uri': instance.uri,
  'name': instance.name,
  'mimeType': instance.mimeType,
  'sizeInBytes': instance.sizeInBytes,
  'dateAddedInMillis': instance.dateAddedInMillis,
  'dateModifiedInMillis': instance.dateModifiedInMillis,
  'dateTakenInMillis': instance.dateTakenInMillis,
  'volumeInfo': instance.volumeInfo,
  'relativePath': instance.relativePath,
  'ownerPackageName': instance.ownerPackageName,
  'isPending': instance.isPending,
  'isTrashed': instance.isTrashed,
  'isFavorite': instance.isFavorite,
  'isDownloaded': instance.isDownloaded,
};

const _$MediaTypeEnumMap = {MediaType.photo: 'PHOTO', MediaType.video: 'VIDEO'};
