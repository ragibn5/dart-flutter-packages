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

  const GetDocumentRequest({required this.treeUri, required this.path});

  @override
  List<Object?> get props => [treeUri, path];

  Map<String, dynamic> toJson() => _$GetDocumentRequestToJson(this);

  factory GetDocumentRequest.fromJson(Map<String, dynamic> json) =>
      _$GetDocumentRequestFromJson(json);
}
