// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/features/settings/application/services/app_locale_resolver.dart';
import 'package:app_template/features/settings/domain/entities/app_locale.dart';
import 'package:app_template/features/settings/domain/entities/locale_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  const localeComponents = LocaleComponents(languageCode: 'en');

  late AppLocaleResolver sut;

  setUpAll(() {
    registerFallbackValue(localeComponents);
  });

  setUp(() {
    sut = AppLocaleResolver();
  });

  test(
    'Should return matching AppLocale if language+script+country matches with any supported one',
    () {
      const localeComponents = LocaleComponents(
        languageCode: 'en',
        scriptCode: 'Latn',
        countryCode: 'US',
      );

      final result = sut.resolveLocale(localeComponents);

      expect(result, AppLocale.EN);
    },
  );

  test(
    'Should return matching AppLocale if language+script matches with any supported one',
    () {
      const localeComponents = LocaleComponents(
        languageCode: 'en',
        scriptCode: 'Latn',
      );

      final result = sut.resolveLocale(localeComponents);

      expect(result, AppLocale.EN);
    },
  );

  test(
    'Should return matching AppLocale if language+country matches with any supported one',
    () {
      const localeComponents = LocaleComponents(
        languageCode: 'en',
        countryCode: 'US',
      );

      final result = sut.resolveLocale(localeComponents);

      expect(result, AppLocale.EN);
    },
  );

  test(
    'Should return matching AppLocale if only language match completely with any supported one',
    () {
      const localeComponents = LocaleComponents(languageCode: 'en');

      final result = sut.resolveLocale(localeComponents);

      expect(result, AppLocale.EN);
    },
  );

  test(
    'Should return null if locale components do not match (not even partially) with any supported ones',
    () {
      const localeComponents = LocaleComponents(languageCode: 'fr');

      final result = sut.resolveLocale(localeComponents);

      expect(result, isNull);
    },
  );

  test('Should return best match in case of partial match', () {
    const localComponentsList = [
      LocaleComponents(
        languageCode: 'en',
        scriptCode: 'Latn',
        countryCode: 'US',
      ),
      LocaleComponents(languageCode: 'en', scriptCode: 'Latn'),
      LocaleComponents(languageCode: 'en', countryCode: 'US'),
      LocaleComponents(languageCode: 'en'),
    ];

    for (final localeComponents in localComponentsList) {
      final result = sut.resolveLocale(localeComponents);
      expect(result, AppLocale.EN);
    }
  });
}
