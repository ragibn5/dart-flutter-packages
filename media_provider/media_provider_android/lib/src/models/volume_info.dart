import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'volume_info.g.dart';

@JsonSerializable()
@immutable
class VolumeInfo extends Equatable {
  /// Whether this is the primary shared/external storage volume.
  final bool isPrimary;

  /// The filesystem UUID of the volume, or null when the platform does not
  /// report one.
  ///
  /// > Note: This may not be available when the volume is not mounted,
  /// > or in case of incompatible volumes.
  final String? uuid;

  const VolumeInfo({required this.isPrimary, required this.uuid});

  factory VolumeInfo.fromJson(Map<String, dynamic> json) =>
      _$VolumeInfoFromJson(json);

  Map<String, dynamic> toJson() => _$VolumeInfoToJson(this);

  @override
  List<Object?> get props => [isPrimary, uuid];
}
