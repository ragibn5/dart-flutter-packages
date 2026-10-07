import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// A storage volume media can be searched on.
///
/// Matches a volume reported by
/// `android.provider.MediaStore.getExternalVolumeNames`.
@immutable
sealed class AndroidStorageVolume extends Equatable {
  final bool isPrimary;
  final String uuid;

  /// Creates a storage volume.
  const AndroidStorageVolume();

  @override
  List<Object?> get props => const [];
}

/// The primary shared storage volume.
final class AndroidPrimaryStorageVolume extends AndroidStorageVolume {
  /// Creates the primary storage volume descriptor.
  const AndroidPrimaryStorageVolume();
}

/// A secondary (external) shared storage volume, identified by its UUID.
final class AndroidExternalStorageVolume extends AndroidStorageVolume {
  /// The UUID identifying the volume.
  final String uuid;

  /// Creates an external storage volume descriptor for [uuid].
  const AndroidExternalStorageVolume(this.uuid);

  @override
  List<Object?> get props => [uuid];
}
