// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:app_template/core/converters/data_domain_converter.dart';
import 'package:app_template/features/settings/data/models/settings_dto.dart';
import 'package:app_template/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:app_template/features/settings/data/sources/settings_data_source.dart';
import 'package:app_template/features/settings/domain/models/app_locale.dart';
import 'package:app_template/features/settings/domain/models/app_settings.dart';
import 'package:app_template/features/settings/domain/models/app_theme_mode.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsConverter extends Mock
    implements DataDomainConverter<SettingsDTO, AppSettings> {}

class _MockSettingsStreamController extends Mock
    implements StreamController<AppSettings> {}

class _MockSettingsDataSource extends Mock implements SettingsDataSource {}

void main() {
  const settingsDto = SettingsDTO(
    locale: AppLocale.EN,
    themeMode: AppThemeMode.LIGHT,
  );

  const settings = AppSettings(
    locale: AppLocale.EN,
    themeMode: AppThemeMode.LIGHT,
  );

  late _MockSettingsConverter mockSettingsConverter;
  late _MockSettingsStreamController mockSettingsStreamController;
  late _MockSettingsDataSource mockSettingsDataSource;

  late SettingsRepositoryImpl sut;

  setUpAll(() {
    registerFallbackValue(settings);
    registerFallbackValue(settingsDto);
  });

  setUp(() {
    mockSettingsConverter = _MockSettingsConverter();
    mockSettingsStreamController = _MockSettingsStreamController();
    mockSettingsDataSource = _MockSettingsDataSource();

    sut = SettingsRepositoryImpl.test(
      mockSettingsConverter,
      mockSettingsStreamController,
      mockSettingsDataSource,
    );

    when(
      () => mockSettingsConverter.convertDataToDomain(settingsDto),
    ).thenReturn(settings);
    when(
      () => mockSettingsConverter.convertDomainToData(settings),
    ).thenReturn(settingsDto);
    when(() => mockSettingsStreamController.add(any())).thenAnswer((_) {});
    when(
      () => mockSettingsStreamController.close(),
    ).thenAnswer((_) async => null);
    when(
      () => mockSettingsDataSource.getCurrentSettings(),
    ).thenAnswer((_) async => settingsDto);
    when(
      () => mockSettingsDataSource.setCurrentSettings(settingsDto),
    ).thenAnswer((_) async {});
  });

  test(
    '`getCurrentSettings` should return shell AppSettings if data source returned null',
    () async {
      when(
        () => mockSettingsDataSource.getCurrentSettings(),
      ).thenAnswer((_) async => null);

      final result = await sut.getCurrentSettings();
      expect(result, const AppSettings());
      verify(() => mockSettingsDataSource.getCurrentSettings()).called(1);
      verifyNever(() => mockSettingsConverter.convertDataToDomain(any()));
    },
  );

  test(
    '`getCurrentSettings` should return correct domain model if data source returned non-null',
    () async {
      final result = await sut.getCurrentSettings();

      expect(result.locale, settingsDto.locale);
      expect(result.themeMode, settingsDto.themeMode);
      verify(() => mockSettingsDataSource.getCurrentSettings()).called(1);
      verify(
        () => mockSettingsConverter.convertDataToDomain(settingsDto),
      ).called(1);
    },
  );

  test(
    '`setCurrentSettings` should add to stream, and call data source',
    () async {
      await sut.setCurrentSettings(settings);

      verify(() => mockSettingsStreamController.add(settings)).called(1);
      verify(
        () => mockSettingsDataSource.setCurrentSettings(settingsDto),
      ).called(1);
    },
  );

  test('`dispose` should close the stream', () async {
    await sut.dispose();
    verify(() => mockSettingsStreamController.close()).called(1);
  });
}
