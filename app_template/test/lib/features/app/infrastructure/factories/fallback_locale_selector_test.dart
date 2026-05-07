// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars

import 'package:app_template/features/app/infrastructure/factories/fallback_locale_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPlatformDispatcher extends Mock implements PlatformDispatcher {}

void main() {
  late _MockPlatformDispatcher mockPlatformDispatcher;

  late FallbackLocaleSelector sut;

  setUp(() {
    mockPlatformDispatcher = _MockPlatformDispatcher();

    sut = const FallbackLocaleSelector();
  });

  test('Select platform locale if it matches one of supported locales', () {
    when(() => mockPlatformDispatcher.locale).thenReturn(const Locale('bn'));

    expect(
      sut.determineDefaultLocale(const Locale('en'), [
        const Locale('en'),
        const Locale('bn'),
        const Locale('fr'),
      ], mockPlatformDispatcher),
      const Locale('bn'),
    );
  });

  test(
    'Fallback locale is selected if platform locale was not matched with supported locales',
    () {
      when(() => mockPlatformDispatcher.locale).thenReturn(const Locale('es'));

      expect(
        sut.determineDefaultLocale(const Locale('en'), [
          const Locale('en'),
          const Locale('bn'),
          const Locale('fr'),
        ], mockPlatformDispatcher),
        const Locale('en'),
      );
    },
  );
}
