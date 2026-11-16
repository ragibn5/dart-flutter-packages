import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'user_identity.g.dart';

@JsonSerializable()
@immutable
class UserIdentity extends Equatable {
  /// The uid of the running process.
  ///
  /// For example `1010123`.
  final int uid;

  /// The id of the user the process runs under.
  ///
  /// For example `0`, `10` etc.
  final int userId;

  /// The id of the app within its user.
  ///
  /// For example `10123`.
  final int appId;

  const UserIdentity({
    required this.uid,
    required this.userId,
    required this.appId,
  });

  factory UserIdentity.fromJson(Map<String, dynamic> json) =>
      _$UserIdentityFromJson(json);

  Map<String, dynamic> toJson() => _$UserIdentityToJson(this);

  @override
  List<Object?> get props => [uid, userId, appId];
}
