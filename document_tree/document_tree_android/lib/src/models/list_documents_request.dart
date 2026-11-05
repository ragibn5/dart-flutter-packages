import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'list_documents_request.g.dart';

/// A request to list the documents in a folder of a tree.
@immutable
@JsonSerializable()
class ListDocumentsRequest extends Equatable {
  /// The tree's URI.
  final String treeUri;

  /// The folder to list, relative to the tree's root, such as `DCIM/Camera`;
  /// empty for the root.
  final String path;

  /// Whether to list the folder's subfolders too, all the way down.
  final bool recursive;

  const ListDocumentsRequest({
    required this.treeUri,
    this.path = '',
    this.recursive = false,
  });

  @override
  List<Object?> get props => [treeUri, path, recursive];

  Map<String, dynamic> toJson() => _$ListDocumentsRequestToJson(this);

  factory ListDocumentsRequest.fromJson(Map<String, dynamic> json) =>
      _$ListDocumentsRequestFromJson(json);
}
