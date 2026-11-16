import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'document_info.g.dart';

/// A file or folder in a tree.
///
/// Note:
/// Always readable: the tree's grant covers everything in it, and a listing
/// fails as a whole if the tree can't be read. Whether it can be written to
/// varies; see [canWrite].
@JsonSerializable()
@immutable
class DocumentInfo extends Equatable {
  /// The document's URI, within the tree's grant.
  final String uri;

  /// Where it is, relative to the tree's root, such as
  /// `DCIM/Camera/IMG_1.jpg`.
  final String path;

  /// Its name, as its provider shows it.
  final String displayName;

  /// Whether it's a folder.
  final bool isDirectory;

  /// Whether the grant allows writing, and the document accepts it: a file
  /// can be overwritten, or a folder can take new documents.
  final bool canWrite;

  /// Its MIME type, such as `image/jpeg`; folders have
  /// `vnd.android.document/directory`.
  final String mimeType;

  /// Its size in bytes, or `null` for folders, or when its provider doesn't
  /// tell.
  final int? sizeInBytes;

  /// When it was last modified, in milliseconds since the epoch, or `null`
  /// if its provider doesn't tell.
  final int? lastModifiedInMillis;

  const DocumentInfo({
    required this.uri,
    required this.path,
    required this.displayName,
    required this.isDirectory,
    required this.canWrite,
    required this.mimeType,
    required this.sizeInBytes,
    required this.lastModifiedInMillis,
  });

  /// The folder it's in, relative to the tree's root, such as `DCIM/Camera`;
  /// empty for a document at the tree's root.
  String get parentPath {
    final index = path.lastIndexOf('/');
    return index == -1 ? '' : path.substring(0, index);
  }

  factory DocumentInfo.fromJson(Map<String, dynamic> json) =>
      _$DocumentInfoFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentInfoToJson(this);

  @override
  List<Object?> get props => [
    uri,
    path,
    displayName,
    isDirectory,
    canWrite,
    mimeType,
    sizeInBytes,
    lastModifiedInMillis,
  ];
}
