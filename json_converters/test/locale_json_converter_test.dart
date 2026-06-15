// ignore_for_file: lines_longer_than_80_chars

import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:json_converters/json_converters.dart';

void main() {
  const sut = LocaleJsonConverter();

  group('`fromJson` valid input', () {
    test('Language only', () {
      expect(sut.fromJson('en').languageCode, 'en');
      expect(sut.fromJson('cel').languageCode, 'cel');
    });

    test('Language + script', () {
      final locale = sut.fromJson('zh-Hans');
      expect(locale.languageCode, 'zh');
      expect(locale.scriptCode, 'Hans');
    });

    test('Language + country', () {
      final locale = sut.fromJson('en-US');
      expect(locale.languageCode, 'en');
      expect(locale.countryCode, 'US');
    });

    test('Language + script + country', () {
      final locale = sut.fromJson('zh-Hans-CN');
      expect(locale.languageCode, 'zh');
      expect(locale.scriptCode, 'Hans');
      expect(locale.countryCode, 'CN');
    });

    test('Unconventional ordering normalizes segments', () {
      final locale = sut.fromJson('en-US-Latn');
      expect(locale.languageCode, 'en');
      expect(locale.scriptCode, 'Latn');
      expect(locale.countryCode, 'US');
    });
  });

  group('`fromJson` invalid input', () {
    test('Invalid language code', () {
      expect(() => sut.fromJson(''), throwsA(isA<FormatException>()));
      expect(() => sut.fromJson('e'), throwsA(isA<FormatException>()));
      expect(() => sut.fromJson('engl'), throwsA(isA<FormatException>()));
    });

    test('Duplicate or out-of-order segments', () {
      expect(
        () => sut.fromJson('zh-Hans-Latn'),
        throwsA(isA<FormatException>()),
      );
      expect(() => sut.fromJson('en-US-GB'), throwsA(isA<FormatException>()));
    });

    test('Invalid segment length', () {
      expect(() => sut.fromJson('en-123'), throwsA(isA<FormatException>()));
      expect(() => sut.fromJson('en-001'), throwsA(isA<FormatException>()));
    });
  });

  group('Round-trip', () {
    for (final entry in <Locale, String>{
      const Locale.fromSubtags(languageCode: 'en'): 'en',
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'):
          'zh-Hans',
      const Locale.fromSubtags(languageCode: 'en', countryCode: 'US'): 'en-US',
      const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hans',
        countryCode: 'CN',
      ): 'zh-Hans-CN',
    }.entries) {
      test(entry.value, () {
        expect(sut.toJson(entry.key), entry.value);
        final parsed = sut.fromJson(entry.value);
        expect(sut.toJson(parsed), entry.value);
      });
    }

    test('Unconventional ordering normalizes', () {
      expect(sut.toJson(sut.fromJson('en-US-Latn')), 'en-Latn-US');
    });
  });
}
