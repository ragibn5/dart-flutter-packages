// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileLocation _$FileLocationFromJson(Map<String, dynamic> json) => FileLocation(
  volumeIdentity: VolumeIdentity.fromJson(
    json['volumeIdentity'] as Map<String, dynamic>,
  ),
  relativeParentPath: json['relativeParentPath'] as String,
  fileNameWithExtension: json['fileNameWithExtension'] as String,
);

Map<String, dynamic> _$FileLocationToJson(FileLocation instance) =>
    <String, dynamic>{
      'volumeIdentity': instance.volumeIdentity.toJson(),
      'relativeParentPath': instance.relativeParentPath,
      'fileNameWithExtension': instance.fileNameWithExtension,
    };
