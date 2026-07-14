import 'package:test/test.dart';
import 'package:collection_utils/collection_utils.dart';

void main() {
  group('ListExtension.replaceWhere', () {
    test('Should replace matching elements', () {
      final list = [1, 2, 3, 4, 5];

      final result = list.replaceWhere(
        (e) => e.isEven,
        replacement: (old) => old * 2,
      );

      expect(result, [1, 4, 3, 8, 5]);
    });

    test('Should not replace elements when no match is found', () {
      final list = [1, 2, 3, 4, 5];

      final result = list.replaceWhere(
        (e) => e > 10,
        replacement: (old) => old * 2,
      );

      expect(result, [1, 2, 3, 4, 5]);
    });

    test('Should replace all matching elements', () {
      final list = ['apple', 'banana', 'cherry', 'apple'];

      final result = list.replaceWhere(
        (e) => e == 'apple',
        replacement: (old) => 'orange',
      );

      expect(result, ['orange', 'banana', 'cherry', 'orange']);
    });

    test('Should replace elements based on complex conditions', () {
      final list = [1, 2, 3, 4, 5, 6];

      final result = list.replaceWhere(
        (e) => e.isEven && e > 2,
        replacement: (old) => old * 10,
      );

      expect(result, [1, 2, 3, 40, 5, 60]);
    });

    test('Should return an empty list when the original list is empty', () {
      final list = <int>[];

      final result = list.replaceWhere(
        (e) => e > 0,
        replacement: (old) => old * 2,
      );

      expect(result, <int>[]);
    });

    test('Should return an empty list when no element matches the condition',
        () {
      final list = [1, 2, 3, 4, 5];

      final result = list.replaceWhere(
        (e) => e > 10,
        replacement: (old) => old * 2,
      );

      expect(result, [1, 2, 3, 4, 5]);
    });
  });
}
