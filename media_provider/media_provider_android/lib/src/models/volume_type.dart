import 'package:json_annotation/json_annotation.dart';

/// The type of a volume.
@JsonEnum(alwaysCreate: true)
enum VolumeType {
  /// The primary shared external volume.
  @JsonValue('PRIMARY')
  primary,

  /// A removable SD card, typically enclosed within device casing.
  @JsonValue('SD_CARD')
  sdCard,

  /// A removable USB drive, connected via the USB interface.
  @JsonValue('USB_DRIVE')
  usbDrive,

  /// A removable drive, but it could not be decided whether it is an SD card
  /// or a USB drive.
  @JsonValue('UNKNOWN_REMOVABLE')
  unknownRemovable,

  /// Unknown volume type.
  @JsonValue('UNKNOWN')
  unknown,
}
