// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:app_template/features/app/application/use_cases/watch_theme_mode_use_case.dart';
import 'package:app_template/features/app/domain/entities/app_settings.dart';
import 'package:app_template/features/app/domain/entities/app_theme_mode.dart';
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

    when(
      () => mockSettingsRepository.getSettingsStream(),
    ).thenAnswer((_) => const Stream.empty());
  });

  Future<void> testThemeModeStream(
    AppSettings appSettings,
    AppThemeMode expected,
  ) async {
    when(
      () => mockSettingsRepository.getSettingsStream(),
    ).thenAnswer((_) => Stream.fromIterable([appSettings]));

    final result = sut();
    expect(await result.first, expected);
  }

  test(
    'Stream obtained from `call` emits SYSTEM when no theme mode is set',
    () async {
      await testThemeModeStream(const AppSettings(), AppThemeMode.SYSTEM);
    },
  );

  test('Stream obtained from `call` emits persisted theme mode', () async {
    await testThemeModeStream(
      const AppSettings(themeMode: AppThemeMode.DARK),
      AppThemeMode.DARK,
    );
  });
}
