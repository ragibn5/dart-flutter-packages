// ignore_for_file: lines_longer_than_80_chars

import 'package:collection_utils/collection_utils.dart';
import 'package:test/test.dart';

void main() {
  group('SetExtension.replaceWhere', () {
    test('should replace matching elements', () {
      final set = {1, 2, 3, 4, 5};

      final result = set.replaceWhere(
        (e) => e.isEven,
        replacement: (old) => old * 2,
      );

      expect(result, {1, 4, 3, 8, 5});
    });

    test('Should not replace elements when no match is found', () {
      final set = {1, 2, 3, 4, 5};

      final result = set.replaceWhere(
        (e) => e > 10,
        replacement: (old) => old * 2,
      );

      expect(result, {1, 2, 3, 4, 5});
    });

    test('Should replace all matching elements', () {
      // ignore: equal_elements_in_set
      final set = {'apple', 'banana', 'cherry', 'apple'};

      final result = set.replaceWhere(
        (e) => e == 'apple',
        replacement: (old) => 'orange',
      );

      expect(result, {'orange', 'banana', 'cherry'});
    });

    test('Should replace elements based on complex conditions', () {
      final set = {1, 2, 3, 4, 5, 6};

      final result = set.replaceWhere(
        (e) => e.isEven && e > 2,
        replacement: (old) => old * 10,
      );

      expect(result, {1, 2, 3, 40, 5, 60});
    });

    test('Should return an empty set when the original set is empty', () {
      final set = <int>{};

      final result = set.replaceWhere(
        (e) => e > 0,
        replacement: (old) => old * 2,
      );

      expect(result, <int>{});
    });

    test(
        'Should return a set with original elements when no element matches the condition',
        () {
      final set = {1, 2, 3, 4, 5};

      final result = set.replaceWhere(
        (e) => e > 10,
        replacement: (old) => old * 2,
      );

      expect(result, {1, 2, 3, 4, 5});
    });

    test('Should replace elements when only one element matches', () {
      final set = {1, 2, 3};

      final result = set.replaceWhere(
        (e) => e == 2,
        replacement: (old) => old * 5,
      );

      expect(result, {1, 10, 3});
    });
  });
}
