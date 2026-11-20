import 'package:document_tree_android/src/models/document_info.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'get_document_request.g.dart';

/// A request to describe one document in a tree.
@immutable
@JsonSerializable()
class GetDocumentRequest extends Equatable {
  /// The tree's URI.
  final String treeUri;

  /// The document, relative to the tree's root, such as
  /// `DCIM/Camera/IMG_1.jpg`; empty for the root.
  final String path;

  /// The URI of the folder holding [path], from an earlier
  /// [DocumentInfo.uri]; `null` when it isn't known.
  ///
  /// Note:
  /// - Only a shortcut: it's used while that folder exists under the name
  ///   [path] gives it; otherwise the folder is found by [path].
  /// - Unused when [path] is empty.
  final String? parentUri;

  const GetDocumentRequest({
    required this.treeUri,
    required this.path,
    this.parentUri,
  });

  @override
  List<Object?> get props => [treeUri, path, parentUri];

  Map<String, dynamic> toJson() => _$GetDocumentRequestToJson(this);

  factory GetDocumentRequest.fromJson(Map<String, dynamic> json) =>
      _$GetDocumentRequestFromJson(json);
}
