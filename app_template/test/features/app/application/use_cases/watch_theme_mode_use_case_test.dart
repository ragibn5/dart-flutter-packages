// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:app_template/features/app/application/use_cases/watch_theme_mode_use_case.dart';
import 'package:app_template/features/app/domain/models/app_settings.dart';
import 'package:app_template/features/app/domain/models/app_theme_mode.dart';
import 'package:app_template/features/app/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockSettingsRepository mockSettingsRepository;

  late WatchThemeModeUseCase sut;

  setUpAll(() {
    registerFallbackValue(const AppSettings());
  });

  setUp(() {
    mockSettingsRepository = _MockSettingsRepository();

    sut = WatchThemeModeUseCase(mockSettingsRepository);
  });

  test('Should call repository.getSettingsStream', () {
    when(
      () => mockSettingsRepository.getSettingsStream(),
    ).thenAnswer((_) => const Stream.empty());

    sut();

    verify(() => mockSettingsRepository.getSettingsStream()).called(1);
  });

  test('Should map settings to theme mode', () async {
    const appSettings = AppSettings(themeMode: AppThemeMode.DARK);
    when(
      () => mockSettingsRepository.getSettingsStream(),
    ).thenAnswer((_) => Stream.fromIterable([appSettings]));

    final result = await sut().first;

    expect(result, AppThemeMode.DARK);
  });

  test('Should emit distinct theme modes', () async {
    const darkA = AppSettings(themeMode: AppThemeMode.DARK);
    const darkB = AppSettings(themeMode: AppThemeMode.DARK);
    const light = AppSettings(themeMode: AppThemeMode.LIGHT);
    when(
      () => mockSettingsRepository.getSettingsStream(),
    ).thenAnswer((_) => Stream.fromIterable([darkA, darkB, light]));

    final result = await sut().toList();

    expect(result, [AppThemeMode.DARK, AppThemeMode.LIGHT]);
  });
}
