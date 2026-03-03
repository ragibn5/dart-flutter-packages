// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/features/settings/data/mappers/settings_mapper.dart';
import 'package:app_template/features/settings/data/models/settings_dto.dart';
import 'package:app_template/features/settings/domain/models/app_locale.dart';
import 'package:app_template/features/settings/domain/models/app_settings.dart';
import 'package:app_template/features/settings/domain/models/app_theme_mode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const settingsDto = SettingsDTO(
    locale: AppLocale.EN,
    themeMode: AppThemeMode.LIGHT,
  );

  const settings = AppSettings(
    locale: AppLocale.EN,
    themeMode: AppThemeMode.LIGHT,
  );

  late SettingsMapper settingsMapper;

  setUp(() {
    settingsMapper = SettingsMapper();
  });

  test('Should encode to correct domain model', () {
    final domainModel = settingsMapper.convertDataToDomain(settingsDto);
    expect(domainModel.locale, settingsDto.locale);
    expect(domainModel.themeMode, settingsDto.themeMode);
  });

  test('Should decode to correct data model', () {
    final dataModel = settingsMapper.convertDomainToData(settings);
    expect(dataModel.locale, settings.locale);
    expect(dataModel.themeMode, settings.themeMode);
  });
}
