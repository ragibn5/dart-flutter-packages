import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:media_provider_android/src/models/volume_identity.dart';
import 'package:media_provider_android/src/models/volume_state.dart';
import 'package:meta/meta.dart';

part 'volume_info.g.dart';

/// A storage volume the device has, as reported by `getVolumes`.
@JsonSerializable()
@immutable
class VolumeInfo extends Equatable {
  /// What identifies the volume.
  final VolumeIdentity identity;

  /// Where the volume currently is in its lifecycle.
  @JsonKey(unknownEnumValue: VolumeState.unknown)
  final VolumeState state;

  /// The space still available on the volume, in bytes.
  ///
  /// Can be zero if the availability could not be read.
  final int availableSpaceInBytes;

  const VolumeInfo({
    required this.identity,
    required this.state,
    required this.availableSpaceInBytes,
  });

  factory VolumeInfo.fromJson(Map<String, dynamic> json) =>
      _$VolumeInfoFromJson(json);

  Map<String, dynamic> toJson() => _$VolumeInfoToJson(this);

  @override
  List<Object?> get props => [identity, state, availableSpaceInBytes];
}
