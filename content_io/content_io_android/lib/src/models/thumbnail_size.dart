import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'thumbnail_size.g.dart';

/// The size a thumbnail is requested at, in pixels.
///
/// Note:
/// The platform returns the thumbnail closest to this size, which may differ
/// from it.
@immutable
@JsonSerializable()
class ThumbnailSize extends Equatable {
  /// The width, in pixels; must be positive.
  final int width;

  /// The height, in pixels; must be positive.
  final int height;

  /// Creates a thumbnail size.
  ///
  /// Parameters:
  /// - [width]: the width, in pixels; must be positive.
  /// - [height]: the height, in pixels; must be positive.
  const ThumbnailSize({required this.width, required this.height})
    : assert(width > 0, 'width must be positive'),
      assert(height > 0, 'height must be positive');

  @override
  List<Object?> get props => [width, height];

  Map<String, dynamic> toJson() => _$ThumbnailSizeToJson(this);

  factory ThumbnailSize.fromJson(Map<String, dynamic> json) =>
      _$ThumbnailSizeFromJson(json);
}
