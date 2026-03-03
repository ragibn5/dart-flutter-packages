// ignore_for_file: lines_longer_than_80_chars

import 'dart:convert';

import 'package:app_template/core/infrastructure/storage/preference/preference_store.dart';
import 'package:app_template/features/settings/data/models/settings_dto.dart';
import 'package:app_template/features/settings/data/sources/settings_data_source_impl.dart';
import 'package:app_template/features/settings/domain/models/app_locale.dart';
import 'package:app_template/features/settings/domain/models/app_settings.dart';
import 'package:app_template/features/settings/domain/models/app_theme_mode.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPreferenceStore extends Mock implements PreferenceStore {}

void main() {
  const settingsDto = SettingsDTO(
    locale: AppLocale.EN,
    themeMode: AppThemeMode.LIGHT,
  );
  final encodedSettingsDto = jsonEncode(settingsDto.toJson());

  const settings = AppSettings(
    locale: AppLocale.EN,
    themeMode: AppThemeMode.LIGHT,
  );

  late _MockPreferenceStore mockPreferenceStore;

  late SettingsDataSourceImpl settingsDataSourceImpl;

  setUpAll(() {
    registerFallbackValue(settings);
    registerFallbackValue(settingsDto);
  });

  setUp(() {
    mockPreferenceStore = _MockPreferenceStore();
    settingsDataSourceImpl = SettingsDataSourceImpl(mockPreferenceStore);

    when(
      () => mockPreferenceStore.getString(SettingsDataSourceImpl.preferenceKey),
    ).thenAnswer((_) async => encodedSettingsDto);
    when(
      () => mockPreferenceStore.setString(
        SettingsDataSourceImpl.preferenceKey,
        any(),
      ),
    ).thenAnswer((_) async {});
  });

  test('`getCurrentSettings` should return correct dto', () async {
    final result = await settingsDataSourceImpl.getCurrentSettings();
    expect(result.locale, settingsDto.locale);
    expect(result.themeMode, settingsDto.themeMode);
    verify(
      () => mockPreferenceStore.getString(SettingsDataSourceImpl.preferenceKey),
    ).called(1);
  });

  test(
    '`setCurrentSettings` should call preference store with correct value',
    () async {
      await settingsDataSourceImpl.setCurrentSettings(settingsDto);

      verify(
        () => mockPreferenceStore.setString(
          SettingsDataSourceImpl.preferenceKey,
          encodedSettingsDto,
        ),
      );
    },
  );
}
