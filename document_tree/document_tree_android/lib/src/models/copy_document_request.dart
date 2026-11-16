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
  /// `DCIM/Camera/IMG_1.jpg`. The missing folders on the way are created.
  final String path;

  /// The copy's MIME type, or `null` to tell it from [path]'s extension, then
  /// from the source.
  final String? mimeType;

  /// Whether to replace a file already at [path]; if not, the copy fails.
  final bool overwrite;

  const CopyDocumentRequest({
    required this.sourceUri,
    required this.treeUri,
    required this.path,
    this.mimeType,
    this.overwrite = false,
  });

  @override
  List<Object?> get props => [sourceUri, treeUri, path, mimeType, overwrite];

  Map<String, dynamic> toJson() => _$CopyDocumentRequestToJson(this);

  factory CopyDocumentRequest.fromJson(Map<String, dynamic> json) =>
      _$CopyDocumentRequestFromJson(json);
}
