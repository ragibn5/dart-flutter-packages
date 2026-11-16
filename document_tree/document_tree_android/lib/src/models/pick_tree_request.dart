import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'pick_tree_request.g.dart';

/// A request to let the user pick a document tree.
@immutable
@JsonSerializable()
class PickTreeRequest extends Equatable {
  /// The URI the picker starts at, such as the current tree's, or `null` for
  /// the system's default.
  ///
  /// Note:
  /// Ignored below Android 8.0 (API 26).
  final String? initialUri;

  const PickTreeRequest({this.initialUri});

  @override
  List<Object?> get props => [initialUri];

  Map<String, dynamic> toJson() => _$PickTreeRequestToJson(this);

  factory PickTreeRequest.fromJson(Map<String, dynamic> json) =>
      _$PickTreeRequestFromJson(json);
}
