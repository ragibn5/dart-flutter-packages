// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/features/app/application/use_cases/get_theme_mode_use_case.dart';
import 'package:app_template/features/app/domain/models/app_settings.dart';
import 'package:app_template/features/app/domain/models/app_theme_mode.dart';
import 'package:app_template/features/app/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockSettingsRepository mockSettingsRepository;

  late GetThemeModeUseCase sut;

  setUpAll(() {
    registerFallbackValue(const AppSettings());
  });

  setUp(() {
    mockSettingsRepository = _MockSettingsRepository();

    sut = GetThemeModeUseCase(mockSettingsRepository);

    when(
      () => mockSettingsRepository.getCurrentSettings(),
    ).thenAnswer((_) async => const AppSettings());
  });

  test('Should return persisted theme mode when available', () async {
    when(
      () => mockSettingsRepository.getCurrentSettings(),
    ).thenAnswer((_) async => const AppSettings(themeMode: AppThemeMode.DARK));

    final result = await sut();

    expect(result, AppThemeMode.DARK);
  });

  test('Should return SYSTEM when no theme mode is persisted', () async {
    final result = await sut();

    expect(result, AppThemeMode.SYSTEM);
  });
}
