import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'delete_document_request.g.dart';

/// A request to delete a document: a file, or a folder with everything
/// in it.
@immutable
@JsonSerializable()
class DeleteDocumentRequest extends Equatable {
  /// The tree's URI.
  final String treeUri;

  /// The document, relative to the tree's root, such as
  /// `DCIM/Camera/IMG_1.jpg`.
  final String path;

  const DeleteDocumentRequest({required this.treeUri, required this.path});

  @override
  List<Object?> get props => [treeUri, path];

  Map<String, dynamic> toJson() => _$DeleteDocumentRequestToJson(this);

  factory DeleteDocumentRequest.fromJson(Map<String, dynamic> json) =>
      _$DeleteDocumentRequestFromJson(json);
}
