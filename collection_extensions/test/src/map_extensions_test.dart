import 'package:collection_extensions/collection_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('MapExtension.replaceWhere', () {
    group('replaceWhereValue', () {
      test('Should replace values when they match the condition', () {
        final map = {'a': 1, 'b': 2, 'c': 3};

        final result = map.replaceWhereValue(
          (value) => value.isEven,
          replacement: (oldValue) => oldValue * 10,
        );

        expect(result, {'a': 1, 'b': 20, 'c': 3});
      });

      test('Should not replace values when no value matches the condition', () {
        final map = {'a': 1, 'b': 2, 'c': 3};

        final result = map.replaceWhereValue(
          (value) => value > 5,
          replacement: (oldValue) => oldValue * 10,
        );

        expect(result, {'a': 1, 'b': 2, 'c': 3});
      });

      test('Should replace all matching values', () {
        final map = {'a': 'apple', 'b': 'banana', 'c': 'apple'};

        final result = map.replaceWhereValue(
          (value) => value == 'apple',
          replacement: (oldValue) => 'orange',
        );

        expect(result, {'a': 'orange', 'b': 'banana', 'c': 'orange'});
      });

      test('Should return an empty map when the original map is empty', () {
        final map = <String, int>{};

        final result = map.replaceWhereValue(
          (value) => value > 0,
          replacement: (oldValue) => oldValue * 2,
        );

        expect(result, <String, int>{});
      });
    });

    group('replaceWhereEntry', () {
      test('Should replace entries when they match the condition', () {
        final map = {'a': 1, 'b': 2, 'c': 3};

        final result = map.replaceWhereEntry(
          (entry) => entry.value.isEven,
          replacement: (oldEntry) =>
              MapEntry(oldEntry.key, oldEntry.value * 10),
        );

        expect(result, {'a': 1, 'b': 20, 'c': 3});
      });

      test('Should not replace entries when no entry matches the condition',
          () {
        final map = {'a': 1, 'b': 2, 'c': 3};

        final result = map.replaceWhereEntry(
          (entry) => entry.value > 5,
          replacement: (oldEntry) =>
              MapEntry(oldEntry.key, oldEntry.value * 10),
        );

        expect(result, {'a': 1, 'b': 2, 'c': 3});
      });

      test('Should replace entries based on complex conditions', () {
        final map = {'a': 1, 'b': 2, 'c': 3, 'd': 4};

        final result = map.replaceWhereEntry(
          (entry) => entry.value.isEven,
          replacement: (oldEntry) =>
              MapEntry(oldEntry.key, oldEntry.value * 10),
        );

        expect(result, {'a': 1, 'b': 20, 'c': 3, 'd': 40});
      });

      test('Should return an empty map when the original map is empty', () {
        final map = <String, int>{};

        final result = map.replaceWhereEntry(
          (entry) => entry.value > 0,
          replacement: (oldEntry) => MapEntry(oldEntry.key, oldEntry.value * 2),
        );

        expect(result, <String, int>{});
      });
    });
  });
}
