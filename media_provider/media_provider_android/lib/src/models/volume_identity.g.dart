// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'volume_identity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VolumeIdentity _$VolumeIdentityFromJson(Map<String, dynamic> json) =>
    VolumeIdentity(
      uuid: json['uuid'] as String?,
      type: $enumDecode(
        _$VolumeTypeEnumMap,
        json['type'],
        unknownValue: VolumeType.unknown,
      ),
      volumePath: json['volumePath'] as String,
      capacityInBytes: (json['capacityInBytes'] as num?)?.toInt(),
      isPrimary: json['isPrimary'] as bool,
      isRemovable: json['isRemovable'] as bool,
      isEmulated: json['isEmulated'] as bool,
    );

Map<String, dynamic> _$VolumeIdentityToJson(VolumeIdentity instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'type': _$VolumeTypeEnumMap[instance.type]!,
      'volumePath': instance.volumePath,
      'capacityInBytes': instance.capacityInBytes,
      'isPrimary': instance.isPrimary,
      'isRemovable': instance.isRemovable,
      'isEmulated': instance.isEmulated,
    };

const _$VolumeTypeEnumMap = {
  VolumeType.primary: 'PRIMARY',
  VolumeType.sdCard: 'SD_CARD',
  VolumeType.usbDrive: 'USB_DRIVE',
  VolumeType.unknownRemovable: 'UNKNOWN_REMOVABLE',
  VolumeType.unknown: 'UNKNOWN',
};
