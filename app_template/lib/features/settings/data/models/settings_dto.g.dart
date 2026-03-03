// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsDTO _$SettingsDTOFromJson(Map<String, dynamic> json) => SettingsDTO(
  themeMode: const AppThemeModeMapper().fromJson(json['theme_mode'] as String?),
  locale: const AppLocaleMapper().fromJson(json['locale'] as String?),
);

Map<String, dynamic> _$SettingsDTOToJson(SettingsDTO instance) =>
    <String, dynamic>{
      'locale': ?const AppLocaleMapper().toJson(instance.locale),
      'theme_mode': ?const AppThemeModeMapper().toJson(instance.themeMode),
    };
