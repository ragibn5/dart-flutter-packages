import 'package:document_tree_android/src/models/content_hash.dart';
import 'package:document_tree_android/src/models/copy_document_request.dart';
import 'package:document_tree_android/src/models/document_info.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'copied_document.g.dart';

/// A file copied into a tree.
@immutable
@JsonSerializable()
class CopiedDocument extends Equatable {
  /// The copy.
  final DocumentInfo document;

  /// The hash of the bytes written into the copy, made with the request's
  /// [CopyDocumentRequest.hashAlgorithm]; `null` when it asked for none.
  final ContentHash? contentHash;

  const CopiedDocument({required this.document, this.contentHash});

  @override
  List<Object?> get props => [document, contentHash];

  Map<String, dynamic> toJson() => _$CopiedDocumentToJson(this);

  factory CopiedDocument.fromJson(Map<String, dynamic> json) =>
      _$CopiedDocumentFromJson(json);
}
