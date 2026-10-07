import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'android_storage_volume_info.g.dart';

@JsonSerializable()
@immutable
class AndroidStorageVolumeInfo extends Equatable {
  /// Whether this is the primary shared/external storage volume.
  final bool isPrimary;

  /// The filesystem UUID of the volume, or null when the platform does not
  /// report one.
  ///
  /// > Note: This may not be available when the volume is not mounted,
  /// > or in case of incompatible volumes.
  final String? uuid;

  const AndroidStorageVolumeInfo({required this.isPrimary, required this.uuid});

  factory AndroidStorageVolumeInfo.fromJson(Map<String, dynamic> json) =>
      _$AndroidStorageVolumeInfoFromJson(json);

  Map<String, dynamic> toJson() => _$AndroidStorageVolumeInfoToJson(this);

  @override
  List<Object?> get props => [isPrimary, uuid];
}
