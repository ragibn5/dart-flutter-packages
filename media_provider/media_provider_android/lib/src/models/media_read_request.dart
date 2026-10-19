import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'media_read_request.g.dart';

/// Describes which `MediaStore` item to read, and how.
@immutable
@JsonSerializable()
class MediaReadRequest extends Equatable {
  /// The `content://` URI of an existing `MediaStore` item, for example
  /// `content://media/external/images/media/42`.
  final String uri;

  /// Whether to read the original bytes, without location redaction.
  ///
  /// From API level 29 (Q), `MediaStore` may redact location metadata (for
  /// example Exif GPS tags) from the bytes it returns. Setting this requests
  /// the original contents through `MediaStore.setRequireOriginal`, which
  /// needs the `ACCESS_MEDIA_LOCATION` permission. Has no effect below API
  /// level 29.
  ///
  /// Set it when the bytes may be written back: overwriting an item with
  /// redacted bytes permanently drops its location data.
  final bool requireOriginal;

  const MediaReadRequest({required this.uri, this.requireOriginal = false});

  @override
  List<Object?> get props => [uri, requireOriginal];

  Map<String, dynamic> toJson() => _$MediaReadRequestToJson(this);

  factory MediaReadRequest.fromJson(Map<String, dynamic> json) =>
      _$MediaReadRequestFromJson(json);

  MediaReadRequest copyWith({String? uri, bool? requireOriginal}) {
    return MediaReadRequest(
      uri: uri ?? this.uri,
      requireOriginal: requireOriginal ?? this.requireOriginal,
    );
  }
}
