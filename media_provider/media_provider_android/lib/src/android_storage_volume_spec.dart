import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'android_storage_volume_spec.g.dart';

/// A storage volume media can be searched on.
///
/// Matches a volume reported by
/// `android.provider.MediaStore.getExternalVolumeNames`.
@immutable
@JsonSerializable(constructor: '_')
class AndroidStorageVolumeSpec extends Equatable {
  /// Whether this volume is the primary shared/external storage volume.
  final bool isPrimary;

  /// The filesystem UUID of the volume.
  ///
  /// > Note:
  /// > - This must be non-null for non-primary external volumes.
  /// > - For primary volume, this field is not relevant and not used.
  final String? uuid;

  factory AndroidStorageVolumeSpec.primary() =>
      const AndroidStorageVolumeSpec._(isPrimary: true);

  factory AndroidStorageVolumeSpec.external({required String uuid}) =>
      AndroidStorageVolumeSpec._(isPrimary: false, uuid: uuid);

  const AndroidStorageVolumeSpec._({required this.isPrimary, this.uuid});

  Map<String, dynamic> toJson() => _$AndroidStorageVolumeSpecToJson(this);

  factory AndroidStorageVolumeSpec.fromJson(Map<String, dynamic> json) =>
      _$AndroidStorageVolumeSpecFromJson(json);

  @override
  List<Object?> get props => [isPrimary, uuid];
}
