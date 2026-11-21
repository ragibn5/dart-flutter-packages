import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'tree_location.g.dart';

/// Where a tree is on the device's storage, confirmed, never guessed.
///
/// How it's found:
/// - Android 10 and later: from the tree folder's own MediaStore row, through
///   documented calls (`MediaStore.getMediaUri`, then the row's volume name,
///   relative path and display name, which the tree's grant lets the app
///   read). It works for folders MediaStore marks as not media, such as ones
///   under a `.nomedia` file.
/// - Android 7 to 9, which have none of these calls: from the storage
///   provider's document ID, `<volume id>:<relative path>`, a shape Android
///   doesn't document. It's accepted only for a mounted volume. When the app
///   holds the storage permission, the folder it names must also exist and
///   hold the same entries as the tree.
///
/// A tree whose location can't be confirmed this way has none
/// (`DocumentTree.location` is `null`), rather than a possibly wrong one.
@JsonSerializable()
@immutable
class TreeLocation extends Equatable {
  /// `primary` for the primary shared storage, or the volume's filesystem
  /// UUID, such as `B63B-1E04`.
  final String volumeId;

  /// The tree's folder, relative to the volume's root, such as
  /// `IntelliSync`; empty for the root itself.
  final String relativePath;

  const TreeLocation({required this.volumeId, required this.relativePath});

  factory TreeLocation.fromJson(Map<String, dynamic> json) =>
      _$TreeLocationFromJson(json);

  Map<String, dynamic> toJson() => _$TreeLocationToJson(this);

  @override
  List<Object?> get props => [volumeId, relativePath];
}
