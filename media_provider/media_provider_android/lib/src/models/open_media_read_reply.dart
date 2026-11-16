import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'open_media_read_reply.g.dart';

/// The platform's reply to `openMediaReadSession`: how the item can be read.
@immutable
sealed class OpenMediaReadReply extends Equatable {
  const OpenMediaReadReply();

  /// Decodes a reply.
  ///
  /// Parameters:
  /// - [json]: the decoded reply; its `kind` selects the subtype.
  ///
  /// Returns: a [DescriptorReply] for `descriptor`, or a [ChannelReply] for
  /// `channel`.
  ///
  /// Throws:
  /// - [FormatException] if `kind` is missing or unknown.
  factory OpenMediaReadReply.fromJson(Map<String, dynamic> json) {
    final kind = json['kind'];
    return switch (kind) {
      'descriptor' => DescriptorReply.fromJson(json),
      'channel' => ChannelReply.fromJson(json),
      _ => throw FormatException('Unknown read source kind: $kind'),
    };
  }
}

/// A file descriptor handed over to Dart.
///
/// Note:
/// The platform keeps no session for it; the receiver owns the descriptor and
/// must close it.
@immutable
@JsonSerializable(createToJson: false)
final class DescriptorReply extends OpenMediaReadReply {
  /// The file descriptor.
  final int fd;

  /// The offset of the item's first byte in the descriptor. Non-zero for a
  /// section of a larger file.
  @JsonKey(defaultValue: 0)
  final int offset;

  /// The size of the item in bytes, or `null` if unknown.
  final int? sizeInBytes;

  /// Whether the descriptor can be read at an offset.
  final bool isSeekable;

  const DescriptorReply({
    required this.fd,
    required this.offset,
    required this.sizeInBytes,
    required this.isSeekable,
  });

  factory DescriptorReply.fromJson(Map<String, dynamic> json) =>
      _$DescriptorReplyFromJson(json);

  @override
  List<Object?> get props => [fd, offset, sizeInBytes, isSeekable];
}

/// A platform-side session, read over the method channel.
@immutable
@JsonSerializable(createToJson: false)
final class ChannelReply extends OpenMediaReadReply {
  /// The id of the platform-side session.
  final String sessionId;

  /// The size of the item in bytes, or `null` if unknown.
  final int? sizeInBytes;

  /// Whether the session can be read at an offset.
  final bool isSeekable;

  const ChannelReply({
    required this.sessionId,
    required this.sizeInBytes,
    required this.isSeekable,
  });

  factory ChannelReply.fromJson(Map<String, dynamic> json) =>
      _$ChannelReplyFromJson(json);

  @override
  List<Object?> get props => [sessionId, sizeInBytes, isSeekable];
}
