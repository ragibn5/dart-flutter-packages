// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:app_template/features/app/application/use_cases/watch_settings_use_case.dart';
import 'package:app_template/features/app/application/use_cases/watch_theme_mode_use_case.dart';
import 'package:app_template/features/app/domain/models/app_settings.dart';
import 'package:app_template/features/app/domain/models/app_theme_mode.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockWatchSettingsUseCase extends Mock implements WatchSettingsUseCase {}

void main() {
  late _MockWatchSettingsUseCase mockWatchSettings;

  late WatchThemeModeUseCase sut;

  setUpAll(() {
    registerFallbackValue(const AppSettings());
  });

  setUp(() {
    mockWatchSettings = _MockWatchSettingsUseCase();

    sut = WatchThemeModeUseCase(mockWatchSettings);
  });

  test('Should call WatchSettingsUseCase', () {
    when(() => mockWatchSettings()).thenAnswer((_) => const Stream.empty());

    sut();

    verify(() => mockWatchSettings()).called(1);
  });

  test('Should map settings to theme mode', () async {
    const appSettings = AppSettings(themeMode: AppThemeMode.DARK);
    when(
      () => mockWatchSettings(),
    ).thenAnswer((_) => Stream.fromIterable([appSettings]));

    final result = await sut().first;

    expect(result, AppThemeMode.DARK);
  });

  test('Should emit distinct theme modes', () async {
    const darkA = AppSettings(themeMode: AppThemeMode.DARK);
    const darkB = AppSettings(themeMode: AppThemeMode.DARK);
    const light = AppSettings(themeMode: AppThemeMode.LIGHT);
    when(
      () => mockWatchSettings(),
    ).thenAnswer((_) => Stream.fromIterable([darkA, darkB, light]));

    final result = await sut().toList();

    expect(result, [AppThemeMode.DARK, AppThemeMode.LIGHT]);
  });
}
