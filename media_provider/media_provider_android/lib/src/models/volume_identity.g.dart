// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'volume_identity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VolumeIdentity _$VolumeIdentityFromJson(Map<String, dynamic> json) =>
    VolumeIdentity(
      isPrimary: json['isPrimary'] as bool,
      isRemovable: json['isRemovable'] as bool,
      isEmulated: json['isEmulated'] as bool,
      type: $enumDecode(_$VolumeTypeEnumMap, json['type']),
      uuid: json['uuid'] as String?,
    );

Map<String, dynamic> _$VolumeIdentityToJson(VolumeIdentity instance) =>
    <String, dynamic>{
      'isPrimary': instance.isPrimary,
      'isRemovable': instance.isRemovable,
      'isEmulated': instance.isEmulated,
      'type': _$VolumeTypeEnumMap[instance.type]!,
      'uuid': instance.uuid,
    };

const _$VolumeTypeEnumMap = {
  VolumeType.primary: 'PRIMARY',
  VolumeType.sdCard: 'SD_CARD',
  VolumeType.usbDrive: 'USB_DRIVE',
  VolumeType.unknownRemovable: 'UNKNOWN_REMOVABLE',
  VolumeType.unknown: 'UNKNOWN',
};
