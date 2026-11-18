import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'rename_document_request.g.dart';

/// A request to rename a document in its folder.
@immutable
@JsonSerializable()
class RenameDocumentRequest extends Equatable {
  /// The tree's URI.
  final String treeUri;

  /// The document, relative to the tree's root, such as
  /// `DCIM/Camera/IMG_1.jpg`.
  final String path;

  /// The document's new name, such as `IMG_2.jpg`; not a path.
  final String newName;

  const RenameDocumentRequest({
    required this.treeUri,
    required this.path,
    required this.newName,
  });

  @override
  List<Object?> get props => [treeUri, path, newName];

  Map<String, dynamic> toJson() => _$RenameDocumentRequestToJson(this);

  factory RenameDocumentRequest.fromJson(Map<String, dynamic> json) =>
      _$RenameDocumentRequestFromJson(json);
}
