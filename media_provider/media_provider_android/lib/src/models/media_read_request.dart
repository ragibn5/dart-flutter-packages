import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:media_provider_android/media_provider_android.dart';
import 'package:meta/meta.dart';

part 'media_read_request.g.dart';

@immutable
@JsonSerializable()
class MediaReadRequest extends Equatable {
  /// The id of the [MediaReadSession] to read from.
  ///
  /// Note: Must be a valid session id obtained from `openMediaReadSession`.
  final String sessionId;

  /// The offset in bytes to start reading from.
  ///
  /// Note: Must be >=0 and <= [MediaReadSession.sizeInBytes].
  final int start;

  /// The count of bytes to read.
  /// Notes:
  /// - This must be >= 0.
  /// - The actual length of returned bytes may be less depending on availability.
  final int length;

  const MediaReadRequest({
    required this.sessionId,
    required this.start,
    required this.length,
  });

  @override
  List<Object?> get props => [sessionId, start, length];

  Map<String, dynamic> toJson() => _$MediaReadRequestToJson(this);

  factory MediaReadRequest.fromJson(Map<String, dynamic> json) =>
      _$MediaReadRequestFromJson(json);
}
