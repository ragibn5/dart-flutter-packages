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
  /// Can be null if the availability could not be read.
  final int? availableSpaceInBytes;

  /// The volume's root in the system's documents provider, such as
  /// `content://com.android.externalstorage.documents/root/B63B-1E04`.
  ///
  /// Start the folder picker here to let the user pick a folder on this
  /// volume. Can be null if the volume has no root there.
  final String? documentsRootUri;

  const VolumeInfo({
    required this.identity,
    required this.state,
    required this.availableSpaceInBytes,
    required this.documentsRootUri,
  });

  factory VolumeInfo.fromJson(Map<String, dynamic> json) =>
      _$VolumeInfoFromJson(json);

  Map<String, dynamic> toJson() => _$VolumeInfoToJson(this);

  @override
  List<Object?> get props => [
    identity,
    state,
    availableSpaceInBytes,
    documentsRootUri,
  ];
}
