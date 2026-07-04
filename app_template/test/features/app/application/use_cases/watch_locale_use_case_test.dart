// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:app_template/features/app/application/use_cases/watch_locale_use_case.dart';
import 'package:app_template/features/app/application/use_cases/watch_settings_use_case.dart';
import 'package:app_template/features/app/domain/models/app_locale.dart';
import 'package:app_template/features/app/domain/models/app_settings.dart';
import 'package:app_template/features/app/domain/models/locale_components.dart';
import 'package:app_template/features/app/domain/services/local_components_mapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockWatchSettingsUseCase extends Mock implements WatchSettingsUseCase {}

class _MockLocalComponentsMapper extends Mock
    implements LocalComponentsMapper {}

void main() {
  late _MockWatchSettingsUseCase mockWatchSettings;
  late _MockLocalComponentsMapper mockLocalComponentsMapper;

  late WatchLocaleUseCase sut;

  setUpAll(() {
    registerFallbackValue(const AppSettings());
    registerFallbackValue(const LocaleComponents(languageCode: ''));
  });

  setUp(() {
    mockWatchSettings = _MockWatchSettingsUseCase();
    mockLocalComponentsMapper = _MockLocalComponentsMapper();

    sut = WatchLocaleUseCase(mockWatchSettings, mockLocalComponentsMapper);
  });

  test('Should call WatchSettingsUseCase', () {
    when(() => mockWatchSettings()).thenAnswer((_) => const Stream.empty());

    sut();

    verify(() => mockWatchSettings()).called(1);
  });

  test('Should map locale using LocalComponentsMapper', () async {
    const appSettings = AppSettings(locale: AppLocale.AR);
    const expectedComponents = LocaleComponents(languageCode: 'ar');
    when(
      () => mockWatchSettings(),
    ).thenAnswer((_) => Stream.fromIterable([appSettings]));
    when(
      () => mockLocalComponentsMapper.mapLocaleComponents(AppLocale.AR),
    ).thenReturn(expectedComponents);

    final result = await sut().first;

    expect(result, expectedComponents);
    verify(() => mockLocalComponentsMapper.mapLocaleComponents(AppLocale.AR));
  });

  test('Should emit distinct values', () async {
    const arSettings = AppSettings(locale: AppLocale.AR);
    const enSettings = AppSettings(locale: AppLocale.EN);
    const arComponents = LocaleComponents(languageCode: 'ar');
    const enComponents = LocaleComponents(languageCode: 'en');

    when(
      () => mockLocalComponentsMapper.mapLocaleComponents(AppLocale.AR),
    ).thenReturn(arComponents);
    when(
      () => mockLocalComponentsMapper.mapLocaleComponents(AppLocale.EN),
    ).thenReturn(enComponents);
    when(() => mockWatchSettings()).thenAnswer(
      (_) => Stream.fromIterable([arSettings, arSettings, enSettings]),
    );

    final result = await sut().toList();

    expect(result, [arComponents, enComponents]);
  });
}
