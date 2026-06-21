// ignore_for_file: lines_longer_than_80_chars

import 'dart:ui';

import 'package:app_template/features/settings/domain/models/locale_components.dart';
import 'package:app_template/features/settings/infrastructure/services/platform_settings_provider_impl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockWidgetBinding extends Mock implements WidgetsBinding {}

class _MockPlatformDispatcher extends Mock implements PlatformDispatcher {}

void main() {
  const platformLocale = Locale.fromSubtags(
    languageCode: 'en',
    scriptCode: 'Latn',
    countryCode: 'US',
  );
  const localeComponents = LocaleComponents(
    languageCode: 'en',
    scriptCode: 'Latn',
    countryCode: 'US',
  );

  late _MockWidgetBinding mockWidgetBinding;
  late _MockPlatformDispatcher mockPlatformDispatcher;

  late PlatformSettingsProviderImpl platformSettingsProviderImpl;

  setUpAll(() {
    registerFallbackValue(platformLocale);
    registerFallbackValue(localeComponents);
  });

  setUp(() {
    mockWidgetBinding = _MockWidgetBinding();
    mockPlatformDispatcher = _MockPlatformDispatcher();

    platformSettingsProviderImpl = PlatformSettingsProviderImpl(
      mockWidgetBinding,
    );

    when(
      () => mockWidgetBinding.platformDispatcher,
    ).thenReturn(mockPlatformDispatcher);
    when(() => mockPlatformDispatcher.locale).thenReturn(platformLocale);
  });

  test(
    'Should return correct components from the locale obtained from platform',
    () {
      final result = platformSettingsProviderImpl.getSystemaLocale();

      expect(result, localeComponents);
    },
  );
}
