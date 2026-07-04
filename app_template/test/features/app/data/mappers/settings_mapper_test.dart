// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/features/app/data/mappers/settings_mapper.dart';
import 'package:app_template/features/app/data/models/settings_dto.dart';
import 'package:app_template/features/app/domain/models/app_locale.dart';
import 'package:app_template/features/app/domain/models/app_settings.dart';
import 'package:app_template/features/app/domain/models/app_theme_mode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final settingsDto = SettingsDTO(
    locale: AppLocale.EN.name,
    themeMode: AppThemeMode.LIGHT.name,
  );

  const settings = AppSettings(
    locale: AppLocale.EN,
    themeMode: AppThemeMode.LIGHT,
  );

  late SettingsMapper sut;

  setUp(() {
    sut = SettingsMapper();
  });

  test('Should encode to correct domain model', () {
    final domainModel = sut.convertDataToDomain(settingsDto);
    expect(domainModel.locale.name, settingsDto.locale);
    expect(domainModel.themeMode.name, settingsDto.themeMode);
  });

  test('Should decode to correct data model', () {
    final dataModel = sut.convertDomainToData(settings);
    expect(dataModel.locale, settings.locale.name);
    expect(dataModel.themeMode, settings.themeMode.name);
  });
}
