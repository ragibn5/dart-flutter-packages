// ignore_for_file: lines_longer_than_80_chars

import 'dart:collection';

import 'package:collection_utils/collection_utils.dart';
import 'package:test/test.dart';

void main() {
  group('QueueExtension.replaceWhere', () {
    test('Should replace matching elements', () {
      final queue = Queue.of([1, 2, 3, 4, 5]);

      final result = queue.replaceWhere(
        (e) => e.isEven,
        replacement: (old) => old * 2,
      );

      expect(result, Queue.of([1, 4, 3, 8, 5]));
    });

    test('Should not replace elements when no match is found', () {
      final queue = Queue.of([1, 2, 3, 4, 5]);

      final result = queue.replaceWhere(
        (e) => e > 10,
        replacement: (old) => old * 2,
      );

      expect(result, Queue.of([1, 2, 3, 4, 5]));
    });

    test('Should replace all matching elements', () {
      final queue = Queue.of(['apple', 'banana', 'cherry', 'apple']);

      final result = queue.replaceWhere(
        (e) => e == 'apple',
        replacement: (old) => 'orange',
      );

      expect(result, Queue.of(['orange', 'banana', 'cherry', 'orange']));
    });

    test('Should replace elements based on complex conditions', () {
      final queue = Queue.of([1, 2, 3, 4, 5, 6]);

      final result = queue.replaceWhere(
        (e) => e.isEven && e > 2,
        replacement: (old) => old * 10,
      );

      expect(result, Queue.of([1, 2, 3, 40, 5, 60]));
    });

    test('Should return an empty queue when the original queue is empty', () {
      final queue = Queue<int>();

      final result = queue.replaceWhere(
        (e) => e > 0,
        replacement: (old) => old * 2,
      );

      expect(result, Queue<int>());
    });

    test(
        'Should return a queue with original elements when no element matches the condition',
        () {
      final queue = Queue.of([1, 2, 3, 4, 5]);

      final result = queue.replaceWhere(
        (e) => e > 10,
        replacement: (old) => old * 2,
      );

      expect(result, Queue.of([1, 2, 3, 4, 5]));
    });

    test('Should replace elements when only one element matches', () {
      final queue = Queue.of([1, 2, 3]);

      final result = queue.replaceWhere(
        (e) => e == 2,
        replacement: (old) => old * 5,
      );

      expect(result, Queue.of([1, 10, 3]));
    });
  });
}
