// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/features/app/application/use_cases/get_effective_locale_use_case.dart';
import 'package:app_template/features/app/application/use_cases/get_platform_locale_use_case.dart';
import 'package:app_template/features/app/domain/models/app_locale.dart';
import 'package:app_template/features/app/domain/models/app_settings.dart';
import 'package:app_template/features/app/domain/models/locale_components.dart';
import 'package:app_template/features/app/domain/repositories/settings_repository.dart';
import 'package:app_template/features/app/domain/services/app_locale_resolver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

class _MockGetPlatformLocaleUseCase extends Mock
    implements GetPlatformLocaleUseCase {}

class _MockAppLocaleResolver extends Mock implements AppLocaleResolver {}

void main() {
  late _MockSettingsRepository mockSettingsRepository;
  late _MockGetPlatformLocaleUseCase mockGetPlatformLocale;
  late _MockAppLocaleResolver mockAppLocaleResolver;

  late GetEffectiveLocaleUseCase sut;

  setUpAll(() {
    registerFallbackValue(const LocaleComponents(languageCode: ''));
  });

  setUp(() {
    mockSettingsRepository = _MockSettingsRepository();
    mockGetPlatformLocale = _MockGetPlatformLocaleUseCase();
    mockAppLocaleResolver = _MockAppLocaleResolver();

    sut = GetEffectiveLocaleUseCase(
      mockSettingsRepository,
      mockAppLocaleResolver,
      mockGetPlatformLocale,
    );

    when(
      () => mockSettingsRepository.getCurrentSettings(),
    ).thenAnswer((_) async => const AppSettings(locale: AppLocale.EN));
    when(
      () => mockGetPlatformLocale(),
    ).thenAnswer((_) async => const LocaleComponents(languageCode: 'en'));
  });

  test(
    'If locale is not ${AppLocale.SYSTEM}, returns corresponding LocaleComponents',
    () async {
      when(
        () => mockSettingsRepository.getCurrentSettings(),
      ).thenAnswer((_) async => const AppSettings(locale: AppLocale.EN));

      final result = await sut();

      expect(result, const LocaleComponents(languageCode: 'en'));
      verifyNever(() => mockGetPlatformLocale());
      verifyNever(() => mockAppLocaleResolver.resolverAppLocale(any()));
    },
  );

  test(
    'If locale is ${AppLocale.SYSTEM} and platform locale is supported, returns platform locale components',
    () async {
      const platformComponents = LocaleComponents(
        languageCode: 'ar',
        countryCode: 'SA',
      );

      when(
        () => mockSettingsRepository.getCurrentSettings(),
      ).thenAnswer((_) async => const AppSettings());
      when(
        () => mockGetPlatformLocale(),
      ).thenAnswer((_) async => platformComponents);
      when(
        () => mockAppLocaleResolver.resolverAppLocale(platformComponents),
      ).thenReturn(AppLocale.AR);

      final result = await sut();

      expect(result, const LocaleComponents(languageCode: 'ar'));
    },
  );

  test(
    'If locale is SYSTEM and platform locale is NOT supported, returns EN components',
    () async {
      const unsupportedComponents = LocaleComponents(languageCode: 'fr');

      when(
        () => mockSettingsRepository.getCurrentSettings(),
      ).thenAnswer((_) async => const AppSettings());
      when(
        () => mockGetPlatformLocale(),
      ).thenAnswer((_) async => unsupportedComponents);
      when(
        () => mockAppLocaleResolver.resolverAppLocale(unsupportedComponents),
      ).thenReturn(null);

      final result = await sut();

      expect(result, const LocaleComponents(languageCode: 'en'));
    },
  );
}
