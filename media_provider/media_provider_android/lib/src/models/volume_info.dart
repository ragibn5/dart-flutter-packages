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
  final VolumeState state;

  const VolumeInfo({required this.identity, required this.state});

  factory VolumeInfo.fromJson(Map<String, dynamic> json) =>
      _$VolumeInfoFromJson(json);

  Map<String, dynamic> toJson() => _$VolumeInfoToJson(this);

  @override
  List<Object?> get props => [identity, state];
}
