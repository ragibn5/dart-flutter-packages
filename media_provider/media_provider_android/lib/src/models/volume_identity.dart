import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:media_provider_android/src/models/volume_type.dart';
import 'package:meta/meta.dart';

part 'volume_identity.g.dart';

/// What identifies a storage volume, as opposed to where it is mounted.
@JsonSerializable()
@immutable
class VolumeIdentity extends Equatable {
  /// The filesystem UUID of the volume, or null when the platform does not
  /// report one.
  ///
  /// > Note: This may not be available when the volume is not mounted,
  /// > or in case of incompatible volumes.
  final String? uuid;

  /// The type of the volume.
  @JsonKey(unknownEnumValue: VolumeType.unknown)
  final VolumeType type;

  /// The filesystem path of the volume.
  final String volumePath;

  /// The total capacity of the volume, in bytes.
  ///
  /// Can be null if the capacity could not be read.
  final int? capacityInBytes;

  /// Whether this is the primary shared/external storage volume.
  final bool isPrimary;

  /// Whether this storage volume is removable.
  final bool isRemovable;

  /// Whether this storage volume is emulated.
  final bool isEmulated;

  const VolumeIdentity({
    required this.uuid,
    required this.type,
    required this.volumePath,
    required this.capacityInBytes,
    required this.isPrimary,
    required this.isRemovable,
    required this.isEmulated,
  });

  factory VolumeIdentity.fromJson(Map<String, dynamic> json) =>
      _$VolumeIdentityFromJson(json);

  Map<String, dynamic> toJson() => _$VolumeIdentityToJson(this);

  @override
  List<Object?> get props => [
    uuid,
    type,
    volumePath,
    capacityInBytes,
    isPrimary,
    isRemovable,
    isEmulated,
  ];
}
