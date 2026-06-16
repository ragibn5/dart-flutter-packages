// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/features/settings/data/mappers/app_locale_mapper.dart';
import 'package:app_template/features/settings/domain/models/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocaleMapper sut;

  setUp(() {
    sut = const AppLocaleMapper();
  });

  test('`fromJson` Should return null if given json is null', () {
    final result = sut.fromJson(null);
    expect(result, null);
  });

  test('`fromJson` Should map correct `AppLocale`', () {
    for (final appLocale in AppLocale.values) {
      final result = sut.fromJson(appLocale.name);
      expect(result, appLocale);
    }
  });

  test('`toJson` Should return null if given locale is null', () {
    final result = sut.toJson(null);
    expect(result, null);
  });

  test(
    '`toJson` Should map return correct serialized value for `AppLocale`',
    () {
      for (final appLocale in AppLocale.values) {
        final result = sut.toJson(appLocale);
        expect(result, appLocale.name);
      }
    },
  );
}
