// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:app_template/features/app/application/use_cases/get_platform_locale_use_case.dart';
import 'package:app_template/features/app/application/use_cases/watch_locale_use_case.dart';
import 'package:app_template/features/app/domain/entities/app_locale.dart';
import 'package:app_template/features/app/domain/entities/app_settings.dart';
import 'package:app_template/features/app/domain/entities/locale_components.dart';
import 'package:app_template/features/app/domain/repositories/settings_repository.dart';
import 'package:app_template/features/app/domain/services/app_locale_resolver.dart';
import 'package:app_template/features/app/domain/services/local_components_mapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

class _MockGetPlatformLocaleUseCase extends Mock
    implements GetPlatformLocaleUseCase {}

class _MockAppLocaleResolver extends Mock implements AppLocaleResolver {}

class _MockLocalComponentsMapper extends Mock
    implements LocalComponentsMapper {}

void main() {
  late _MockSettingsRepository mockSettingsRepository;
  late _MockGetPlatformLocaleUseCase mockGetPlatformLocale;
  late _MockAppLocaleResolver mockAppLocaleResolver;
  late _MockLocalComponentsMapper mockLocalComponentsMapper;

  late WatchLocaleUseCase sut;

  setUpAll(() {
    registerFallbackValue(const AppSettings());
    registerFallbackValue(const LocaleComponents(languageCode: ''));
  });

  setUp(() {
    mockSettingsRepository = _MockSettingsRepository();
    mockGetPlatformLocale = _MockGetPlatformLocaleUseCase();
    mockAppLocaleResolver = _MockAppLocaleResolver();
    mockLocalComponentsMapper = _MockLocalComponentsMapper();

    sut = WatchLocaleUseCase(
      mockSettingsRepository,
      mockGetPlatformLocale,
      mockAppLocaleResolver,
      mockLocalComponentsMapper,
    );

    when(
      () => mockSettingsRepository.getSettingsStream(),
    ).thenAnswer((_) => const Stream.empty());
  });

  Future<void> testLocaleStream(
    AppSettings appSettings,
    LocaleComponents systemLocale,
    AppLocale resolvedLocale,
    LocaleComponents expectedComponents,
  ) async {
    when(
      () => mockSettingsRepository.getSettingsStream(),
    ).thenAnswer((_) => Stream.fromIterable([appSettings]));
    when(() => mockGetPlatformLocale()).thenAnswer((_) async => systemLocale);
    when(
      () => mockAppLocaleResolver.resolverAppLocale(systemLocale),
    ).thenReturn(resolvedLocale);
    when(
      () => mockLocalComponentsMapper.mapLocaleComponents(
        appSettings.locale ?? resolvedLocale,
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
        const LocaleComponents(languageCode: 'en'),
        AppLocale.EN,
        const LocaleComponents(languageCode: 'ar'),
      );
    },
  );

  test(
    'Stream emits platform-resolved LocaleComponents when locale is null and platform locale is supported',
    () async {
      await testLocaleStream(
        const AppSettings(),
        const LocaleComponents(languageCode: 'ar', countryCode: 'SA'),
        AppLocale.AR,
        const LocaleComponents(languageCode: 'ar'),
      );
    },
  );

  test(
    'Stream emits EN LocaleComponents when locale is null and platform locale is not supported',
    () async {
      await testLocaleStream(
        const AppSettings(),
        const LocaleComponents(languageCode: 'fr'),
        AppLocale.EN,
        const LocaleComponents(languageCode: 'en'),
      );
    },
  );
}
