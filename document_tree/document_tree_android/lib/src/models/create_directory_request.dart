import 'package:document_tree_android/src/models/document_info.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'create_directory_request.g.dart';

/// A request to create a folder in a tree.
@immutable
@JsonSerializable()
class CreateDirectoryRequest extends Equatable {
  /// The tree's URI.
  final String treeUri;

  /// The folder to create, relative to the tree's root, such as
  /// `DCIM/Archive`. The folder holding it must exist.
  final String path;

  /// The URI of the folder holding [path], from an earlier
  /// [DocumentInfo.uri]; `null` when it isn't known.
  ///
  /// Note:
  /// Only a shortcut: it's used while that folder exists under the name
  /// [path] gives it; otherwise the folder is found by [path].
  final String? parentUri;

  const CreateDirectoryRequest({
    required this.treeUri,
    required this.path,
    this.parentUri,
  });

  @override
  List<Object?> get props => [treeUri, path, parentUri];

  Map<String, dynamic> toJson() => _$CreateDirectoryRequestToJson(this);

  factory CreateDirectoryRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateDirectoryRequestFromJson(json);
}
