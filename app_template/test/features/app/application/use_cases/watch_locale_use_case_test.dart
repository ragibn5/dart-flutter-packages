// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:app_template/features/app/application/use_cases/watch_locale_use_case.dart';
import 'package:app_template/features/app/domain/models/app_locale.dart';
import 'package:app_template/features/app/domain/models/app_settings.dart';
import 'package:app_template/features/app/domain/models/locale_components.dart';
import 'package:app_template/features/app/domain/repositories/settings_repository.dart';
import 'package:app_template/features/app/domain/services/local_components_mapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

class _MockLocalComponentsMapper extends Mock
    implements LocalComponentsMapper {}

void main() {
  late _MockSettingsRepository mockSettingsRepository;
  late _MockLocalComponentsMapper mockLocalComponentsMapper;

  late WatchLocaleUseCase sut;

  setUpAll(() {
    registerFallbackValue(const AppSettings());
    registerFallbackValue(const LocaleComponents(languageCode: ''));
  });

  setUp(() {
    mockSettingsRepository = _MockSettingsRepository();
    mockLocalComponentsMapper = _MockLocalComponentsMapper();

    sut = WatchLocaleUseCase(mockSettingsRepository, mockLocalComponentsMapper);

    when(
      () => mockSettingsRepository.getSettingsStream(),
    ).thenAnswer((_) => const Stream.empty());
  });

  Future<void> testLocaleStream(
    AppSettings appSettings,
    LocaleComponents expectedComponents,
  ) async {
    when(
      () => mockSettingsRepository.getSettingsStream(),
    ).thenAnswer((_) => Stream.fromIterable([appSettings]));
    when(
      () => mockLocalComponentsMapper.mapLocaleComponents(
        appSettings.locale ?? AppLocale.SYSTEM,
      ),
    ).thenReturn(expectedComponents);

    final result = sut();
    expect(await result.first, expectedComponents);
  }

  test(
    'Stream emits mapped LocaleComponents when locale is set in settings',
    () async {
      await testLocaleStream(
        const AppSettings(locale: AppLocale.AR),
        const LocaleComponents(languageCode: 'ar'),
      );
    },
  );

  test('Stream emits SYSTEM LocaleComponents when locale is null', () async {
    await testLocaleStream(
      const AppSettings(),
      const LocaleComponents(languageCode: 'en'),
    );
  });
}
