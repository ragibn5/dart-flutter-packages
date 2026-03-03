// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthDataDTO _$AuthDataDTOFromJson(Map<String, dynamic> json) => AuthDataDTO(
  userId: json['user_id'] as String,
  accessToken: json['access_token'] as String,
  refreshToken: json['refresh_token'] as String,
  accessTokenExpiry: const Rfc3339UTCDateTimeJsonConverter().fromJson(
    json['access_token_expiry'] as String,
  ),
  refreshTokenExpiry: const Rfc3339UTCDateTimeJsonConverter().fromJson(
    json['refresh_token_expiry'] as String,
  ),
);

Map<String, dynamic> _$AuthDataDTOToJson(AuthDataDTO instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'access_token_expiry': const Rfc3339UTCDateTimeJsonConverter().toJson(
        instance.accessTokenExpiry,
      ),
      'refresh_token_expiry': const Rfc3339UTCDateTimeJsonConverter().toJson(
        instance.refreshTokenExpiry,
      ),
    };
