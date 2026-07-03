// ignore_for_file: lines_longer_than_80_chars

import 'dart:convert';

import 'package:app_template/features/app/data/models/settings_dto.dart';
import 'package:app_template/features/app/data/sources/settings_data_source_impl.dart';
import 'package:app_template/features/app/domain/entities/app_locale.dart';
import 'package:app_template/features/app/domain/entities/app_theme_mode.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:preference_store/preference_store.dart';

class _MockPreferenceStore extends Mock implements PreferenceStore {}

void main() {
  const settingsDto = SettingsDTO(
    locale: AppLocale.EN,
    themeMode: AppThemeMode.LIGHT,
  );
  final encodedSettingsDto = jsonEncode(settingsDto.toJson());

  late _MockPreferenceStore mockPreferenceStore;

  late SettingsDataSourceImpl sut;

  setUp(() {
    mockPreferenceStore = _MockPreferenceStore();
    sut = SettingsDataSourceImpl(mockPreferenceStore);

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

  test(
    '`getCurrentSettings` should return null if data is not persisted',
    () async {
      when(
        () => mockPreferenceStore.getString(any()),
      ).thenAnswer((_) async => null);

      final result = await sut.getCurrentSettings();

      expect(result, isNull);
    },
  );

  test('`getCurrentSettings` should return correct dto if persisted', () async {
    final result = await sut.getCurrentSettings();

    expect(result?.locale, settingsDto.locale);
    expect(result?.themeMode, settingsDto.themeMode);
    verify(
      () => mockPreferenceStore.getString(SettingsDataSourceImpl.preferenceKey),
    ).called(1);
  });

  test(
    '`setCurrentSettings` should call preference store with correct value',
    () async {
      await sut.setCurrentSettings(settingsDto);

      verify(
        () => mockPreferenceStore.setString(
          SettingsDataSourceImpl.preferenceKey,
          encodedSettingsDto,
        ),
      );
    },
  );
}
