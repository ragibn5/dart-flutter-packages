import 'package:document_tree_android/src/models/tree_location.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'document_tree.g.dart';

/// A folder the user granted the app persistent access to.
///
/// Note:
/// Always readable: a tree that can't be read is reported as unavailable,
/// not returned. Whether it can be written to varies; see [canWrite].
@JsonSerializable()
@immutable
class DocumentTree extends Equatable {
  /// The tree's URI, such as
  /// `content://com.android.externalstorage.documents/tree/B63B-1E04%3AIntelliSync`.
  final String uri;

  /// The folder's name, as its provider shows it.
  final String displayName;

  /// Whether the grant allows writing, and the folder accepts new documents.
  final bool canWrite;

  /// Where the tree is on the device's storage, or `null` when its provider
  /// isn't the device's storage, such as a cloud drive.
  final TreeLocation? location;

  /// When the user granted the app access, in milliseconds since the epoch.
  final int grantedAtInMillis;

  /// When the folder was last modified, in milliseconds since the epoch, or
  /// `null` if its provider doesn't tell.
  final int? lastModifiedInMillis;

  const DocumentTree({
    required this.uri,
    required this.displayName,
    required this.canWrite,
    required this.location,
    required this.grantedAtInMillis,
    required this.lastModifiedInMillis,
  });

  factory DocumentTree.fromJson(Map<String, dynamic> json) =>
      _$DocumentTreeFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentTreeToJson(this);

  @override
  List<Object?> get props => [
    uri,
    displayName,
    canWrite,
    location,
    grantedAtInMillis,
    lastModifiedInMillis,
  ];
}
