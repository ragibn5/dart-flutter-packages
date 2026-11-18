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

  /// The copy's MIME type, or `null` to tell it from [path]'s extension, then
  /// from the source.
  final String? mimeType;

  const CopyDocumentRequest({
    required this.sourceUri,
    required this.treeUri,
    required this.path,
    this.mimeType,
  });

  @override
  List<Object?> get props => [sourceUri, treeUri, path, mimeType];

  Map<String, dynamic> toJson() => _$CopyDocumentRequestToJson(this);

  factory CopyDocumentRequest.fromJson(Map<String, dynamic> json) =>
      _$CopyDocumentRequestFromJson(json);
}
