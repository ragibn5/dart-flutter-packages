import 'package:app_template/features/app/application/use_cases/set_theme_mode_use_case.dart';
import 'package:app_template/features/app/domain/entities/app_locale.dart';
import 'package:app_template/features/app/domain/entities/app_settings.dart';
import 'package:app_template/features/app/domain/entities/app_theme_mode.dart';
import 'package:app_template/features/app/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockSettingsRepository mockSettingsRepository;

  late SetThemeModeUseCase sut;

  setUpAll(() {
    registerFallbackValue(const AppSettings());
  });

  setUp(() {
    mockSettingsRepository = _MockSettingsRepository();

    sut = SetThemeModeUseCase(mockSettingsRepository);

    when(
      () => mockSettingsRepository.getCurrentSettings(),
    ).thenAnswer((_) async => const AppSettings());
    when(
      () => mockSettingsRepository.setCurrentSettings(any()),
    ).thenAnswer((_) async {});
  });

  test(
    'Should persist given theme mode while keeping other settings unchanged',
    () async {
      const appSettings = AppSettings(
        locale: AppLocale.AR,
        themeMode: AppThemeMode.LIGHT,
      );

      when(
        () => mockSettingsRepository.getCurrentSettings(),
      ).thenAnswer((_) async => appSettings);

      await sut(AppThemeMode.DARK);

      verify(
        () => mockSettingsRepository.setCurrentSettings(
          appSettings.copyWith(themeMode: AppThemeMode.DARK),
        ),
      );
    },
  );
}
