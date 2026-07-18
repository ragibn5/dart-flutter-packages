// ignore_for_file: lines_longer_than_80_chars

import 'package:extended_string/extended_string.dart';
import 'package:test/test.dart';

void main() {
  group('isNullOrEmptyOrBlank', () {
    test(
      'should return true for null',
      () => expect(null.isNullOrEmptyOrBlank, true),
    );
    test(
      'should return true for empty string',
      () => expect(''.isNullOrEmptyOrBlank, true),
    );
    test(
      'should return true for blank string',
      () => expect('   '.isNullOrEmptyOrBlank, true),
    );
    test(
      'should return false for non-empty string',
      () => expect('Hello'.isNullOrEmptyOrBlank, false),
    );
  });

  group('nullOnEmptyOrBlank', () {
    test(
      'should return null for null',
      () => expect(null.nullOnEmptyOrBlank, null),
    );
    test(
      'should return null for empty string',
      () => expect(''.nullOnEmptyOrBlank, null),
    );
    test(
      'should return null for blank string',
      () => expect('   '.nullOnEmptyOrBlank, null),
    );
    test(
      'should return original string for non-empty',
      () => expect('Hello'.nullOnEmptyOrBlank, 'Hello'),
    );
  });
}
