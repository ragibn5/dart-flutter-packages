import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'create_document_request.g.dart';

/// A request to create a file in a tree, optionally with its content.
@immutable
@JsonSerializable()
class CreateDocumentRequest extends Equatable {
  /// The tree's URI.
  final String treeUri;

  /// The file to create, relative to the tree's root, such as
  /// `Backups/notes.json`. The folder holding it must exist, and nothing must
  /// be at it.
  final String path;

  /// The file's MIME type, or `null` to tell it from [path]'s extension.
  final String? mimeType;

  /// The file's content, or `null` to create it empty.
  ///
  /// Note:
  /// It's sent in one piece, so it's meant for small files, such as a few
  /// megabytes at most.
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Uint8List? bytes;

  const CreateDocumentRequest({
    required this.treeUri,
    required this.path,
    this.mimeType,
    this.bytes,
  });

  @override
  List<Object?> get props => [treeUri, path, mimeType, bytes];

  /// The request without its [bytes], which are sent outside the JSON.
  Map<String, dynamic> toJson() => _$CreateDocumentRequestToJson(this);

  factory CreateDocumentRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateDocumentRequestFromJson(json);
}
