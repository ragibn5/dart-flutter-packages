// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/features/settings/domain/models/app_locale.dart';
import 'package:app_template/features/settings/domain/models/locale_components.dart';
import 'package:app_template/features/settings/domain/services/app_locale_resolver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  const localeComponents = LocaleComponents(languageCode: 'en');

  late AppLocaleResolver appLocaleResolver;

  setUpAll(() {
    registerFallbackValue(localeComponents);
  });

  setUp(() {
    appLocaleResolver = AppLocaleResolver();
  });

  test(
    'Should return matching AppLocale if locale components match completely with any supported one',
    () {
      final localeComponents = LocaleComponents(
        languageCode: AppLocale.EN.languageCode,
        scriptCode: AppLocale.EN.scriptCode,
        countryCode: AppLocale.EN.countryCode,
      );

      final result = appLocaleResolver.resolveLocale(localeComponents);

      expect(result, AppLocale.EN);
    },
  );

  test(
    'Should return null if locale components do not match (not even partially) with any supported ones',
    () {
      const localeComponents = LocaleComponents(languageCode: 'fr');

      final result = appLocaleResolver.resolveLocale(localeComponents);

      expect(result, isNull);
    },
  );

  test('Should return best match in case of partial match', () {
    final localComponentsList = [
      LocaleComponents(
        languageCode: AppLocale.EN.languageCode,
        scriptCode: AppLocale.EN.scriptCode,
        countryCode: AppLocale.EN.countryCode,
      ),
      LocaleComponents(
        languageCode: AppLocale.EN.languageCode,
        scriptCode: AppLocale.EN.scriptCode,
      ),
      LocaleComponents(
        languageCode: AppLocale.EN.languageCode,
        countryCode: AppLocale.EN.countryCode,
      ),
      LocaleComponents(languageCode: AppLocale.EN.languageCode),
    ];

    for (final localeComponents in localComponentsList) {
      final result = appLocaleResolver.resolveLocale(localeComponents);
      expect(result, AppLocale.EN);
    }
  });
}
