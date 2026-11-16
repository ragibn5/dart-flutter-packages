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
/// - `{"type":"primary","relativePathScope":""}`
/// - `{"type":"external","uuid":"1a2b-3c4d","relativePathScope":""}`
///
/// The discriminator values are part of the wire format.
/// Changing them requires a matching change in the Kotlin `@SerialName`s.
sealed class VolumeSpec extends Equatable {
  const VolumeSpec();

  /// The primary shared/external storage volume.
  const factory VolumeSpec.primary({String relativePathScope}) =
      PrimaryVolumeSpec;

  /// A secondary external volume, identified by its filesystem [uuid].
  const factory VolumeSpec.external({
    required String uuid,
    String relativePathScope,
  }) = ExternalVolumeSpec;

  /// A path relative to the volume root which the query is scoped to.
  ///
  /// An empty string (the default) searches the whole volume.
  String get relativePathScope;

  /// Decodes a [VolumeSpec] by dispatching on the `"type"` discriminator.
  ///
  /// Throws a [FormatException] if the discriminator is missing or unknown.
  factory VolumeSpec.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    return switch (type) {
      'primary' => PrimaryVolumeSpec.fromJson(json),
      'external' => ExternalVolumeSpec.fromJson(json),
      _ => throw FormatException('Unknown VolumeSpec type: $type'),
    };
  }

  /// Encodes this spec including the `"type"` discriminator.
  Map<String, dynamic> toJson();
}

/// The primary shared/external storage volume.
final class PrimaryVolumeSpec extends VolumeSpec {
  @override
  final String relativePathScope;

  const PrimaryVolumeSpec({this.relativePathScope = ''});

  factory PrimaryVolumeSpec.fromJson(Map<String, dynamic> json) =>
      PrimaryVolumeSpec(
        relativePathScope: json['relativePathScope'] as String? ?? '',
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': 'primary',
    'relativePathScope': relativePathScope,
  };

  @override
  List<Object?> get props => [relativePathScope];
}

/// A secondary external volume (e.g., SD card, USB storage).
@JsonSerializable()
final class ExternalVolumeSpec extends VolumeSpec {
  /// The filesystem UUID of the volume, as reported by the system.
  final String uuid;

  @override
  final String relativePathScope;

  const ExternalVolumeSpec({
    required this.uuid,
    this.relativePathScope = '',
  });

  factory ExternalVolumeSpec.fromJson(Map<String, dynamic> json) =>
      _$ExternalVolumeSpecFromJson(json);

  @override
  Map<String, dynamic> toJson() => {
    'type': 'external',
    ..._$ExternalVolumeSpecToJson(this),
  };

  @override
  List<Object?> get props => [uuid, relativePathScope];
}
