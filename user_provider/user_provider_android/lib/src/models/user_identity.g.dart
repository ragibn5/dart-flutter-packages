// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_identity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserIdentity _$UserIdentityFromJson(Map<String, dynamic> json) => UserIdentity(
  uid: (json['uid'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  appId: (json['appId'] as num).toInt(),
);

Map<String, dynamic> _$UserIdentityToJson(UserIdentity instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'userId': instance.userId,
      'appId': instance.appId,
    };
