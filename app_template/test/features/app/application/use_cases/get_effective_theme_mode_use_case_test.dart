import 'package:app_template/features/app/application/use_cases/get_effective_theme_mode_use_case.dart';
import 'package:app_template/features/app/domain/models/app_settings.dart';
import 'package:app_template/features/app/domain/models/app_theme_mode.dart';
import 'package:app_template/features/app/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockSettingsRepository mockSettingsRepository;

  late GetEffectiveThemeModeUseCase sut;

  setUp(() {
    mockSettingsRepository = _MockSettingsRepository();

    sut = GetEffectiveThemeModeUseCase(mockSettingsRepository);
  });

  test('Should return theme mode from settings repository', () async {
    when(
      () => mockSettingsRepository.getCurrentSettings(),
    ).thenAnswer((_) async => const AppSettings(themeMode: AppThemeMode.DARK));

    final result = await sut();

    expect(result, AppThemeMode.DARK);
  });
}
