import 'package:content_io_android/src/models/write_mode.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'open_write_request.g.dart';

/// A request to open existing content for writing.
///
/// Note:
/// The content must already exist, such as a document created with
/// `document_tree_android`'s `createDocument`; opening doesn't create it.
@immutable
@JsonSerializable()
class OpenWriteRequest extends Equatable {
  /// The `content://` URI of the content to write.
  final String uri;

  /// How to treat the content already there.
  final WriteMode mode;

  const OpenWriteRequest({required this.uri, this.mode = WriteMode.truncate});

  @override
  List<Object?> get props => [uri, mode];

  Map<String, dynamic> toJson() => _$OpenWriteRequestToJson(this);

  factory OpenWriteRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenWriteRequestFromJson(json);
}
