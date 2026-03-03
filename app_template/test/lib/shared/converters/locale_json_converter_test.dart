// ignore_for_file: lines_longer_than_80_chars

import 'dart:ui';

import 'package:app_template/shared/converters/locale_json_converter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const converter = LocaleJsonConverter();

  group('`fromJson` valid combinations', () {
    <String, void Function(Locale)>{
      // language only
      'en': (locale) {
        expect(locale.languageCode, 'en');
        expect(locale.scriptCode, isNull);
        expect(locale.countryCode, isNull);
      },

      // language + script
      'zh-Hans': (locale) {
        expect(locale.languageCode, 'zh');
        expect(locale.scriptCode, 'Hans');
        expect(locale.countryCode, isNull);
      },

      // language + country
      'en-US': (locale) {
        expect(locale.languageCode, 'en');
        expect(locale.scriptCode, isNull);
        expect(locale.countryCode, 'US');
      },

      // language + script + country
      'zh-Hans-CN': (locale) {
        expect(locale.languageCode, 'zh');
        expect(locale.scriptCode, 'Hans');
        expect(locale.countryCode, 'CN');
      },
    }.forEach((input, verify) {
      test('fromJson("$input")', () {
        final locale = converter.fromJson(input);

        expect(locale, isA<Locale>());
        verify(locale);
      });
    });
  });

  group('`toJson` valid combinations', () {
    <Locale, String>{
      // language only
      const Locale.fromSubtags(languageCode: 'en'): 'en',

      // language + script
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'):
          'zh-Hans',

      // language + country
      const Locale.fromSubtags(languageCode: 'en', countryCode: 'US'): 'en-US',

      // language + script + country
      const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hans',
        countryCode: 'CN',
      ): 'zh-Hans-CN',
    }.forEach((locale, expected) {
      test('toJson($locale) -> "$expected"', () {
        final json = converter.toJson(locale);
        expect(json, expected);
      });
    });
  });

  group('`fromJson` invalid cases', () {
    test('invalid language code', () {
      expect(
        () => converter.fromJson('english'),
        throwsA(isA<FormatException>()),
      );
    });

    test('duplicate script', () {
      expect(
        () => converter.fromJson('zh-Hans-Latn'),
        throwsA(isA<FormatException>()),
      );
    });

    test('invalid segment length', () {
      expect(
        () => converter.fromJson('en-123'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
