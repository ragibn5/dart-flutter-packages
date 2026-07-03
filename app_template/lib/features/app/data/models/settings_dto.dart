import 'package:app_template/features/app/data/mappers/app_locale_mapper.dart';
import 'package:app_template/features/app/data/mappers/app_theme_mode_mapper.dart';
import 'package:app_template/features/app/domain/entities/app_locale.dart';
import 'package:app_template/features/app/domain/entities/app_theme_mode.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'settings_dto.g.dart';

@JsonSerializable()
class SettingsDTO extends Equatable {
  @AppLocaleMapper()
  final AppLocale? locale;

  @AppThemeModeMapper()
  final AppThemeMode? themeMode;

  const SettingsDTO({this.themeMode, this.locale});

  factory SettingsDTO.fromJson(Map<String, dynamic> json) =>
      _$SettingsDTOFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsDTOToJson(this);

  @override
  List<Object?> get props => [locale, themeMode];
}
