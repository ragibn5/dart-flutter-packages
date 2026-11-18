import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'open_write_reply.g.dart';

/// The platform's reply to `openWriteSession`: how the content can be
/// written.
@immutable
sealed class OpenWriteReply extends Equatable {
  const OpenWriteReply();

  /// Decodes a reply.
  ///
  /// Parameters:
  /// - [json]: the decoded reply; its `kind` selects the subtype.
  ///
  /// Returns: a [WriteDescriptorReply] for `descriptor`, or a
  /// [WriteChannelReply] for `channel`.
  ///
  /// Throws:
  /// - [FormatException] if `kind` is missing or unknown.
  factory OpenWriteReply.fromJson(Map<String, dynamic> json) {
    final kind = json['kind'];
    return switch (kind) {
      'descriptor' => WriteDescriptorReply.fromJson(json),
      'channel' => WriteChannelReply.fromJson(json),
      _ => throw FormatException('Unknown write sink kind: $kind'),
    };
  }
}

/// A file descriptor handed over to Dart.
///
/// Note:
/// The platform keeps no session for it; the receiver owns the descriptor,
/// and must sync and close it.
@immutable
@JsonSerializable(createToJson: false)
final class WriteDescriptorReply extends OpenWriteReply {
  /// The file descriptor.
  final int fd;

  const WriteDescriptorReply({required this.fd});

  factory WriteDescriptorReply.fromJson(Map<String, dynamic> json) =>
      _$WriteDescriptorReplyFromJson(json);

  @override
  List<Object?> get props => [fd];
}

/// A platform-side session, written over the method channel.
@immutable
@JsonSerializable(createToJson: false)
final class WriteChannelReply extends OpenWriteReply {
  /// The id of the platform-side session.
  final String sessionId;

  const WriteChannelReply({required this.sessionId});

  factory WriteChannelReply.fromJson(Map<String, dynamic> json) =>
      _$WriteChannelReplyFromJson(json);

  @override
  List<Object?> get props => [sessionId];
}
