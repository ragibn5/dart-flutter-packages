import 'package:app_template/features/app/application/use_cases/get_effective_theme_mode_use_case.dart';
import 'package:app_template/features/app/application/use_cases/get_settings_use_case.dart';
import 'package:app_template/features/app/domain/models/app_settings.dart';
import 'package:app_template/features/app/domain/models/app_theme_mode.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetSettingsUseCase extends Mock implements GetSettingsUseCase {}

void main() {
  late _MockGetSettingsUseCase mockGetSettings;

  late GetEffectiveThemeModeUseCase sut;

  setUp(() {
    mockGetSettings = _MockGetSettingsUseCase();

    sut = GetEffectiveThemeModeUseCase(mockGetSettings);
  });

  test('Should return whatever locale $GetSettingsUseCase returns', () async {
    when(
      () => mockGetSettings(),
    ).thenAnswer((_) async => const AppSettings(themeMode: AppThemeMode.DARK));

    final result = await sut();

    expect(result, AppThemeMode.DARK);
  });
}
