import 'package:content_io_android/content_io_android.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'read_request.g.dart';

@immutable
@JsonSerializable()
class ReadRequest extends Equatable {
  /// The id of the [ContentReadSession] to read from.
  ///
  /// Note: Must be a valid session id obtained from `openReadSession`.
  final String sessionId;

  /// The offset in bytes to start reading from.
  ///
  /// Note: Must be >=0 and <= [ContentReadSession.sizeInBytes].
  final int start;

  /// The count of bytes to read.
  /// Notes:
  /// - This must be >= 0.
  /// - The actual length of returned bytes may be less, depending on
  ///   availability.
  final int length;

  const ReadRequest({
    required this.sessionId,
    required this.start,
    required this.length,
  });

  @override
  List<Object?> get props => [sessionId, start, length];

  Map<String, dynamic> toJson() => _$ReadRequestToJson(this);

  factory ReadRequest.fromJson(Map<String, dynamic> json) =>
      _$ReadRequestFromJson(json);
}
