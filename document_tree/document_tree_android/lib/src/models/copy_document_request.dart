import 'package:document_tree_android/src/models/content_hash_algorithm.dart';
import 'package:document_tree_android/src/models/document_info.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'copy_document_request.g.dart';

/// A request to copy a file into a tree.
@immutable
@JsonSerializable()
class CopyDocumentRequest extends Equatable {
  /// The file to copy: any URI the app can open for reading, such as a
  /// `content://` URI from MediaStore, or a `file://` URI the app can read.
  final String sourceUri;

  /// The tree's URI.
  final String treeUri;

  /// Where to put the copy, relative to the tree's root, such as
  /// `DCIM/Camera/IMG_1.jpg`. The folder holding it must exist, and nothing
  /// must be at it.
  final String path;

  /// The URI of the folder holding [path], from an earlier
  /// [DocumentInfo.uri]; `null` when it isn't known.
  ///
  /// Note:
  /// Only a shortcut: it's used while that folder exists under the name
  /// [path] gives it; otherwise the folder is found by [path].
  final String? parentUri;

  /// The copy's MIME type, or `null` to tell it from [path]'s extension, then
  /// from the source.
  final String? mimeType;

  /// The algorithm to hash the copied bytes with, as they're written, or
  /// `null` for no hash.
  ///
  /// Note:
  /// The hash is of exactly what the copy holds, made with no second read.
  final ContentHashAlgorithm? hashAlgorithm;

  const CopyDocumentRequest({
    required this.sourceUri,
    required this.treeUri,
    required this.path,
    this.parentUri,
    this.mimeType,
    this.hashAlgorithm,
  });

  @override
  List<Object?> get props => [
    sourceUri,
    treeUri,
    path,
    parentUri,
    mimeType,
    hashAlgorithm,
  ];

  Map<String, dynamic> toJson() => _$CopyDocumentRequestToJson(this);

  factory CopyDocumentRequest.fromJson(Map<String, dynamic> json) =>
      _$CopyDocumentRequestFromJson(json);
}
