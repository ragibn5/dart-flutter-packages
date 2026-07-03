// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/features/app/application/use_cases/get_effective_locale_use_case.dart';
import 'package:app_template/features/app/application/use_cases/get_locale_use_case.dart';
import 'package:app_template/features/app/application/use_cases/get_platform_locale_use_case.dart';
import 'package:app_template/features/app/domain/models/app_locale.dart';
import 'package:app_template/features/app/domain/models/locale_components.dart';
import 'package:app_template/features/app/domain/services/app_locale_resolver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetLocaleUseCase extends Mock implements GetLocaleUseCase {}

class _MockGetPlatformLocaleUseCase extends Mock
    implements GetPlatformLocaleUseCase {}

class _MockAppLocaleResolver extends Mock implements AppLocaleResolver {}

void main() {
  late _MockGetLocaleUseCase mockGetLocale;
  late _MockGetPlatformLocaleUseCase mockGetPlatformLocale;
  late _MockAppLocaleResolver mockAppLocaleResolver;

  late GetEffectiveLocaleUseCase sut;

  setUpAll(() {
    registerFallbackValue(const LocaleComponents(languageCode: ''));
  });

  setUp(() {
    mockGetLocale = _MockGetLocaleUseCase();
    mockGetPlatformLocale = _MockGetPlatformLocaleUseCase();
    mockAppLocaleResolver = _MockAppLocaleResolver();

    sut = GetEffectiveLocaleUseCase(
      mockAppLocaleResolver,
      mockGetLocale,
      mockGetPlatformLocale,
    );

    when(() => mockGetLocale()).thenAnswer((_) async => AppLocale.EN);
    when(
      () => mockGetPlatformLocale(),
    ).thenAnswer((_) async => const LocaleComponents(languageCode: 'en'));
  });

  test(
    'If a locale setting is persisted, returns corresponding LocaleComponents',
    () async {
      when(() => mockGetLocale()).thenAnswer((_) async => AppLocale.EN);

      final result = await sut();

      expect(result, const LocaleComponents(languageCode: 'en'));
      verifyNever(() => mockGetPlatformLocale());
      verifyNever(() => mockAppLocaleResolver.resolverAppLocale(any()));
    },
  );

  test(
    'If locale is SYSTEM and platform locale is supported, returns platform locale components',
    () async {
      const platformComponents = LocaleComponents(
        languageCode: 'ar',
        countryCode: 'SA',
      );

      when(() => mockGetLocale()).thenAnswer((_) async => AppLocale.SYSTEM);
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

      when(() => mockGetLocale()).thenAnswer((_) async => AppLocale.SYSTEM);
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
