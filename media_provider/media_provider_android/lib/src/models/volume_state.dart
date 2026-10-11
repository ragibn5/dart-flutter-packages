import 'package:json_annotation/json_annotation.dart';

/// The state of a volume.
///
/// Each value is the name of the matching Kotlin `VolumeState` constant, which
/// in turn stands for an `android.os.Environment.MEDIA_*` value.
@JsonEnum(alwaysCreate: true)
enum VolumeState {
  /// The volume is mounted, and can be read from and written to.
  @JsonValue('MOUNTED')
  mounted,

  /// The volume is mounted, but only for reading.
  @JsonValue('MOUNTED_READ_ONLY')
  mountedReadOnly,

  /// The volume is not mounted.
  @JsonValue('UNMOUNTED')
  unmounted,

  /// The volume is being checked, which happens after it was mounted.
  @JsonValue('CHECKING')
  checking,

  /// The volume is being ejected.
  @JsonValue('EJECTING')
  ejecting,

  /// The volume has been removed, and is safe to unmount.
  @JsonValue('REMOVED')
  removed,

  /// The volume was removed without being unmounted first.
  @JsonValue('BAD_REMOVAL')
  badRemoval,

  /// The volume is unmounted, and cannot be mounted.
  @JsonValue('UNMOUNTABLE')
  unmountable,

  /// The volume is unmounted, and carries no filesystem to mount.
  @JsonValue('NO_FILESYSTEM')
  noFilesystem,

  /// The volume reports no state, or one the plugin does not know.
  @JsonValue('UNKNOWN')
  unknown,
}
