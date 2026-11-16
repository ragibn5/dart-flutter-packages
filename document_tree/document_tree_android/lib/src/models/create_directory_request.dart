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

  const CreateDirectoryRequest({required this.treeUri, required this.path});

  @override
  List<Object?> get props => [treeUri, path];

  Map<String, dynamic> toJson() => _$CreateDirectoryRequestToJson(this);

  factory CreateDirectoryRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateDirectoryRequestFromJson(json);
}
