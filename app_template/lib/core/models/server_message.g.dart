// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerMessage _$ServerMessageFromJson(Map<String, dynamic> json) =>
    ServerMessage(
      code: json['code'] as String,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$ServerMessageToJson(ServerMessage instance) =>
    <String, dynamic>{'code': instance.code, 'message': ?instance.message};
