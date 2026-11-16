import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'tree_location.g.dart';

/// Where a tree is on the device's storage.
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
