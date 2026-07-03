// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/features/app/data/mappers/app_theme_mode_mapper.dart';
import 'package:app_template/features/app/domain/models/app_theme_mode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppThemeModeMapper sut;

  setUp(() {
    sut = const AppThemeModeMapper();
  });

  test('`fromJson` Should return null if given json is null', () {
    final result = sut.fromJson(null);
    expect(result, null);
  });

  test('`fromJson` Should map correct `AppThemeMode`', () {
    for (final appThemeMode in AppThemeMode.values) {
      final result = sut.fromJson(appThemeMode.name);
      expect(result, appThemeMode);
    }
  });

  test('`toJson` Should return null if given locale is null', () {
    final result = sut.toJson(null);
    expect(result, null);
  });

  test(
    '`toJson` Should map return correct serialized value for `AppThemeMode`',
    () {
      for (final appThemeMode in AppThemeMode.values) {
        final result = sut.toJson(appThemeMode);
        expect(result, appThemeMode.name);
      }
    },
  );
}
