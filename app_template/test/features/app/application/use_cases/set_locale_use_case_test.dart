import 'package:app_template/features/app/application/use_cases/set_locale_use_case.dart';
import 'package:app_template/features/app/domain/models/app_locale.dart';
import 'package:app_template/features/app/domain/models/app_settings.dart';
import 'package:app_template/features/app/domain/models/app_theme_mode.dart';
import 'package:app_template/features/app/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockSettingsRepository mockSettingsRepository;

  late SetLocaleUseCase sut;

  setUpAll(() {
    registerFallbackValue(const AppSettings());
  });

  setUp(() {
    mockSettingsRepository = _MockSettingsRepository();

    sut = SetLocaleUseCase(mockSettingsRepository);

    when(
      () => mockSettingsRepository.getCurrentSettings(),
    ).thenAnswer((_) async => const AppSettings());
    when(
      () => mockSettingsRepository.setCurrentSettings(any()),
    ).thenAnswer((_) async {});
  });

  test(
    'Should persist given locale while keeping other settings unchanged',
    () async {
      const appSettings = AppSettings(
        locale: AppLocale.EN,
        themeMode: AppThemeMode.DARK,
      );

      when(
        () => mockSettingsRepository.getCurrentSettings(),
      ).thenAnswer((_) async => appSettings);

      await sut(AppLocale.AR);

      verify(
        () => mockSettingsRepository.setCurrentSettings(
          appSettings.copyWith(locale: AppLocale.AR),
        ),
      );
    },
  );
}
