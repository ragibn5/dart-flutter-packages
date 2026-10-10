import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'volume_spec.g.dart';

/// A storage volume media can be searched on.
///
/// Matches a volume reported by
/// `android.provider.MediaStore.getExternalVolumeNames`.
///
/// Serialized polymorphically with a `"type"` discriminator,
/// matching the Android side:
/// - `{"type":"primary"}`
/// - `{"type":"external","uuid":"1a2b-3c4d"}`
///
/// The discriminator values are part of the wire format.
/// Changing them requires a matching change in the Kotlin `@SerialName`s.
sealed class VolumeSpec extends Equatable {
  const VolumeSpec();

  /// The primary shared/external storage volume.
  const factory VolumeSpec.primary() = PrimaryVolumeSpec;

  /// A secondary external volume, identified by its filesystem [uuid].
  const factory VolumeSpec.external({required String uuid}) =
      ExternalVolumeSpec;

  /// Decodes a [VolumeSpec] by dispatching on the `"type"` discriminator.
  ///
  /// Throws a [FormatException] if the discriminator is missing or unknown.
  factory VolumeSpec.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    return switch (type) {
      'primary' => const PrimaryVolumeSpec(),
      'external' => ExternalVolumeSpec.fromJson(json),
      _ => throw FormatException('Unknown VolumeSpec type: $type'),
    };
  }

  /// Encodes this spec including the `"type"` discriminator.
  Map<String, dynamic> toJson();
}

/// The primary shared/external storage volume.
final class PrimaryVolumeSpec extends VolumeSpec {
  const PrimaryVolumeSpec();

  @override
  Map<String, dynamic> toJson() => const {'type': 'primary'};

  @override
  List<Object?> get props => const [];
}

/// A secondary external volume (e.g., SD card, USB storage).
@JsonSerializable()
final class ExternalVolumeSpec extends VolumeSpec {
  /// The filesystem UUID of the volume, as reported by the system.
  final String uuid;

  const ExternalVolumeSpec({required this.uuid});

  factory ExternalVolumeSpec.fromJson(Map<String, dynamic> json) =>
      _$ExternalVolumeSpecFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
    'type': 'external',
    ..._$ExternalVolumeSpecToJson(this),
  };

  @override
  List<Object?> get props => [uuid];
}
