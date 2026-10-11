// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'volume_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VolumeInfo _$VolumeInfoFromJson(Map<String, dynamic> json) => VolumeInfo(
  identity: VolumeIdentity.fromJson(json['identity'] as Map<String, dynamic>),
  state: $enumDecode(
    _$VolumeStateEnumMap,
    json['state'],
    unknownValue: VolumeState.unknown,
  ),
);

Map<String, dynamic> _$VolumeInfoToJson(VolumeInfo instance) =>
    <String, dynamic>{
      'identity': instance.identity,
      'state': _$VolumeStateEnumMap[instance.state]!,
    };

const _$VolumeStateEnumMap = {
  VolumeState.mounted: 'MOUNTED',
  VolumeState.mountedReadOnly: 'MOUNTED_READ_ONLY',
  VolumeState.unmounted: 'UNMOUNTED',
  VolumeState.checking: 'CHECKING',
  VolumeState.ejecting: 'EJECTING',
  VolumeState.removed: 'REMOVED',
  VolumeState.badRemoval: 'BAD_REMOVAL',
  VolumeState.unmountable: 'UNMOUNTABLE',
  VolumeState.noFilesystem: 'NO_FILESYSTEM',
  VolumeState.unknown: 'UNKNOWN',
};
