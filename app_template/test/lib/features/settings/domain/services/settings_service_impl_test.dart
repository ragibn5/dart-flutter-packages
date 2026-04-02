// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/features/settings/domain/models/app_locale.dart';
import 'package:app_template/features/settings/domain/models/app_settings.dart';
import 'package:app_template/features/settings/domain/models/app_theme_mode.dart';
import 'package:app_template/features/settings/domain/models/locale_components.dart';
import 'package:app_template/features/settings/domain/repositories/settings_repository.dart';
import 'package:app_template/features/settings/domain/services/app_locale_resolver.dart';
import 'package:app_template/features/settings/domain/services/platform_settings_provider.dart';
import 'package:app_template/features/settings/domain/services/settings_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAppLocaleResolver extends Mock implements AppLocaleResolver {}

class _MockPlatformSettingsProvider extends Mock
    implements PlatformSettingsProvider {}

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockAppLocaleResolver mockAppLocaleResolver;
  late _MockPlatformSettingsProvider mockPlatformSettingsProvider;
  late _MockSettingsRepository mockSettingsRepository;

  late SettingsServiceImpl sut;

  Future<void> testThemeModeStream(
    AppSettings appSettings,
    AppThemeMode expected,
  ) async {
    when(
      () => mockSettingsRepository.getSettingsStream(),
    ).thenAnswer((_) => Stream.fromIterable([appSettings]));

    final result = sut.watchThemeMode();
    expect(await result.first, expected);
  }

  Future<void> testLocaleStream(
    AppSettings appSettings,
    LocaleComponents systemLocale,
    AppLocale expected,
  ) async {
    when(
      () => mockSettingsRepository.getSettingsStream(),
    ).thenAnswer((_) => Stream.fromIterable([appSettings]));
    when(
      () => mockPlatformSettingsProvider.getSystemaLocale(),
    ).thenAnswer((_) => systemLocale);
    when(
      () => mockAppLocaleResolver.resolveLocale(systemLocale),
    ).thenAnswer((_) => expected);

    final result = sut.watchLocale();
    expect(await result.first, expected);
  }

  setUpAll(() {
    registerFallbackValue(const AppSettings());
    registerFallbackValue(const LocaleComponents(languageCode: 'en'));
  });

  setUp(() {
    mockAppLocaleResolver = _MockAppLocaleResolver();
    mockPlatformSettingsProvider = _MockPlatformSettingsProvider();
    mockSettingsRepository = _MockSettingsRepository();

    sut = SettingsServiceImpl(
      mockAppLocaleResolver,
      mockPlatformSettingsProvider,
      mockSettingsRepository,
    );

    when(
      () => mockSettingsRepository.setCurrentSettings(any()),
    ).thenAnswer((_) async {});
  });

  test(
    'If a locale setting is persisted, `getEffectiveLocale` returns that.',
    () async {
      when(
        () => mockSettingsRepository.getCurrentSettings(),
      ).thenAnswer((_) async => const AppSettings(locale: AppLocale.EN));

      final result = await sut.getEffectiveLocale();
      expect(result, AppLocale.EN);
    },
  );

  test(
    'If a locale setting is NOT persisted, and platform locale is supported, `getEffectiveLocale` returns that.',
    () async {
      const appSettings = AppSettings();
      final localeComponents = LocaleComponents(
        languageCode: AppLocale.AR.languageCode,
        scriptCode: AppLocale.AR.scriptCode,
        countryCode: AppLocale.AR.countryCode,
      );
      when(
        () => mockSettingsRepository.getCurrentSettings(),
      ).thenAnswer((_) async => appSettings);
      when(
        () => mockPlatformSettingsProvider.getSystemaLocale(),
      ).thenAnswer((_) => localeComponents);
      when(
        () => mockAppLocaleResolver.resolveLocale(localeComponents),
      ).thenAnswer((_) => AppLocale.AR);

      final result = await sut.getEffectiveLocale();
      expect(result, AppLocale.AR);
    },
  );

  test(
    'If a locale setting is NOT persisted, and platform locale is NOT supported, `getEffectiveLocale` returns EN.',
    () async {
      const appSettings = AppSettings();
      const localeComponents = LocaleComponents(languageCode: 'fr');
      when(
        () => mockSettingsRepository.getCurrentSettings(),
      ).thenAnswer((_) async => appSettings);
      when(
        () => mockPlatformSettingsProvider.getSystemaLocale(),
      ).thenAnswer((_) => localeComponents);
      when(
        () => mockAppLocaleResolver.resolveLocale(localeComponents),
      ).thenAnswer((_) => AppLocale.EN);

      final result = await sut.getEffectiveLocale();
      expect(result, AppLocale.EN);
    },
  );

  test(
    'If a theme-mode setting is persisted, `getEffectiveThemeMode` returns that.',
    () async {
      when(() => mockSettingsRepository.getCurrentSettings()).thenAnswer(
        (_) async => const AppSettings(themeMode: AppThemeMode.DARK),
      );

      final result = await sut.getEffectiveThemeMode();
      expect(result, AppThemeMode.DARK);
    },
  );

  test(
    'If a theme-mode setting is NOT persisted, SYSTEM is returned',
    () async {
      when(
        () => mockSettingsRepository.getCurrentSettings(),
      ).thenAnswer((_) async => const AppSettings());

      final result = await sut.getEffectiveThemeMode();
      expect(result, AppThemeMode.SYSTEM);
    },
  );

  test(
    '`setLocale` should persist given local settings while keeping other unchanged',
    () async {
      const appSettings = AppSettings(
        locale: AppLocale.EN,
        themeMode: AppThemeMode.DARK,
      );

      when(
        () => mockSettingsRepository.getCurrentSettings(),
      ).thenAnswer((_) async => appSettings);

      await sut.setLocale(AppLocale.AR);
      verify(
        () => mockSettingsRepository.setCurrentSettings(
          appSettings.copyWith(
            locale: AppLocale.AR,
            themeMode: AppThemeMode.DARK,
          ),
        ),
      );
    },
  );

  test(
    '`setThemeMode` should persist given theme-mode settings while keeping other unchanged',
    () async {
      const appSettings = AppSettings(
        locale: AppLocale.AR,
        themeMode: AppThemeMode.LIGHT,
      );

      when(
        () => mockSettingsRepository.getCurrentSettings(),
      ).thenAnswer((_) async => appSettings);

      await sut.setThemeMode(AppThemeMode.DARK);
      verify(
        () => mockSettingsRepository.setCurrentSettings(
          appSettings.copyWith(
            locale: AppLocale.AR,
            themeMode: AppThemeMode.DARK,
          ),
        ),
      );
    },
  );

  test('Stream obtained from `watchLocale` emit correct values', () async {
    await testLocaleStream(
      const AppSettings(locale: AppLocale.AR),
      LocaleComponents(languageCode: AppLocale.EN.languageCode),
      AppLocale.AR,
    );
    await testLocaleStream(
      const AppSettings(),
      LocaleComponents(languageCode: AppLocale.AR.languageCode),
      AppLocale.AR,
    );
    await testLocaleStream(
      const AppSettings(),
      const LocaleComponents(languageCode: 'fr'),
      AppLocale.EN,
    );
  });

  test('Stream obtained from `watchThemeMode` emit correct values', () async {
    await testThemeModeStream(const AppSettings(), AppThemeMode.SYSTEM);
    await testThemeModeStream(
      const AppSettings(themeMode: AppThemeMode.DARK),
      AppThemeMode.DARK,
    );
  });
}
