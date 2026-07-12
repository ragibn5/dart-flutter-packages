// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsDTO _$SettingsDTOFromJson(Map<String, dynamic> json) => SettingsDTO(
  themeMode: json['theme_mode'] as String?,
  locale: json['locale'] as String?,
);

Map<String, dynamic> _$SettingsDTOToJson(SettingsDTO instance) =>
    <String, dynamic>{
      'locale': ?instance.locale,
      'theme_mode': ?instance.themeMode,
    };
