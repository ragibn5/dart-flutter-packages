// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars

import 'package:app_template/features/app/infrastructure/factories/app_config_factory.dart';
import 'package:app_template/features/app/infrastructure/factories/fallback_locale_selector.dart';
import 'package:app_template/generated/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';

class _MockPackageInfo extends Mock implements PackageInfo {}

class _MockPlatformDispatcher extends Mock implements PlatformDispatcher {}

class _MockFallbackLocaleSelector extends Mock
    implements FallbackLocaleSelector {}

class _FakePlatformDispatcher extends Fake implements PlatformDispatcher {}

void main() {
  const PACKAGE_NAME = 'com.ragibn5.fat';
  const PLATFORM_LOCALE = Locale('en-US');
  const DESIGN_SIZE = Size(360, 640);
  final LIGHT_THEME = ThemeData.light();
  final DARK_THEME = ThemeData.dark();
  const THEME_MODE = ThemeMode.system;
  final SUPPORTED_LOCALES = S.delegate.supportedLocales;
  final LOCALIZATION_DELEGATES = <LocalizationsDelegate<dynamic>>[
    S.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  late _MockPackageInfo mockPackageInfo;
  late _MockPlatformDispatcher mockPlatformDispatcher;
  late _MockFallbackLocaleSelector mockFallbackLocaleSelector;

  late AppConfigFactory sut;

  setUpAll(() {
    registerFallbackValue(PLATFORM_LOCALE);
    registerFallbackValue(_FakePlatformDispatcher());
  });

  setUp(() {
    mockPackageInfo = _MockPackageInfo();
    mockPlatformDispatcher = _MockPlatformDispatcher();
    mockFallbackLocaleSelector = _MockFallbackLocaleSelector();

    sut = AppConfigFactory(mockPackageInfo, mockFallbackLocaleSelector);

    when(() => mockPackageInfo.packageName).thenReturn(PACKAGE_NAME);
    when(() => mockPlatformDispatcher.locale).thenReturn(PLATFORM_LOCALE);
    when(
      () => mockFallbackLocaleSelector.determineDefaultLocale(
        any(),
        any(),
        any(),
      ),
    ).thenReturn(PLATFORM_LOCALE);
  });

  test(
    'AppConfigFactory creates AppConfig with correct values (without default locale)',
    () {
      final config = sut.create(mockPlatformDispatcher);

      expect(config.restorationScopeId, PACKAGE_NAME);
      expect(config.designSize, DESIGN_SIZE);
      expect(config.lightThemeData, LIGHT_THEME);
      expect(config.darkThemeData, DARK_THEME);
      expect(config.supportedLocales, SUPPORTED_LOCALES);
      expect(config.defaultThemeMode, THEME_MODE);
      expect(config.defaultLocale, PLATFORM_LOCALE);
      expect(config.localizationDelegates, LOCALIZATION_DELEGATES);
    },
  );
}
