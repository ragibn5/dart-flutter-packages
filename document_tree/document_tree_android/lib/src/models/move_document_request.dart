import 'package:document_tree_android/src/models/document_info.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'move_document_request.g.dart';

/// A request to move a document to another folder in its tree, keeping its
/// name.
@immutable
@JsonSerializable()
class MoveDocumentRequest extends Equatable {
  /// The tree's URI.
  final String treeUri;

  /// The document, relative to the tree's root, such as
  /// `DCIM/Camera/IMG_1.jpg`.
  final String path;

  /// The folder to move it into, relative to the tree's root, such as
  /// `DCIM/Archive`; empty for the root. It must exist.
  final String newParentPath;

  /// The URI of the folder holding [path], from an earlier
  /// [DocumentInfo.uri]; `null` when it isn't known.
  ///
  /// Note:
  /// Only a shortcut: it's used while that folder exists under the name
  /// [path] gives it; otherwise the folder is found by [path].
  final String? parentUri;

  /// The URI of the folder [newParentPath] names, from an earlier
  /// [DocumentInfo.uri]; `null` when it isn't known.
  ///
  /// Note:
  /// Only a shortcut: it's used while that folder exists under the name
  /// [newParentPath] gives it; otherwise the folder is found by
  /// [newParentPath].
  final String? newParentUri;

  const MoveDocumentRequest({
    required this.treeUri,
    required this.path,
    required this.newParentPath,
    this.parentUri,
    this.newParentUri,
  });

  @override
  List<Object?> get props => [
    treeUri,
    path,
    newParentPath,
    parentUri,
    newParentUri,
  ];

  Map<String, dynamic> toJson() => _$MoveDocumentRequestToJson(this);

  factory MoveDocumentRequest.fromJson(Map<String, dynamic> json) =>
      _$MoveDocumentRequestFromJson(json);
}
