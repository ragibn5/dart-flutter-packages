import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:media_provider_android/src/models/volume_type.dart';
import 'package:meta/meta.dart';

part 'volume_identity.g.dart';

/// What identifies a storage volume, as opposed to where it is mounted.
@JsonSerializable()
@immutable
class VolumeIdentity extends Equatable {
  /// Whether this is the primary shared/external storage volume.
  final bool isPrimary;

  /// Whether this storage volume is removable.
  final bool isRemovable;

  /// Whether this storage volume is emulated.
  final bool isEmulated;

  /// The type of the volume.
  @JsonKey(unknownEnumValue: VolumeType.unknown)
  final VolumeType type;

  /// The total capacity of the volume, in bytes.
  ///
  /// Zero when the volume is not mounted and so has no readable filesystem.
  final int capacityInBytes;

  /// The filesystem UUID of the volume, or null when the platform does not
  /// report one.
  ///
  /// > Note: This may not be available when the volume is not mounted,
  /// > or in case of incompatible volumes.
  final String? uuid;

  const VolumeIdentity({
    required this.isPrimary,
    required this.isRemovable,
    required this.isEmulated,
    required this.type,
    required this.capacityInBytes,
    required this.uuid,
  });

  factory VolumeIdentity.fromJson(Map<String, dynamic> json) =>
      _$VolumeIdentityFromJson(json);

  Map<String, dynamic> toJson() => _$VolumeIdentityToJson(this);

  @override
  List<Object?> get props => [
    isPrimary,
    isRemovable,
    isEmulated,
    type,
    capacityInBytes,
    uuid,
  ];
}
