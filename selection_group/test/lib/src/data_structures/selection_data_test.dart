// ignore_for_file: cascade_invocations
// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:selection_group/src/data_structures/selection_data.dart';

void main() {
  late SelectionData selectionData;

  setUp(() {
    selectionData = SelectionData(
      size: 5,
      maxSelectionCount: 3,
    );
  });

  group('Initial state', () {
    test('selectionCount is zero and indices list is empty', () {
      expect(selectionData.selectionCount, 0);
      expect(selectionData.getCurrentSelectionIndices(), isEmpty);
    });

    test('maxSelectionCount getter returns configured value', () {
      expect(selectionData.maxSelectionCount, 3);
    });

    test('maxSelectionCount getter returns null when not configured', () {
      final unlimited = SelectionData(size: 3, maxSelectionCount: null);
      expect(unlimited.maxSelectionCount, isNull);
    });
  });

  group('select', () {
    test('Marks index as selected and increments count', () {
      selectionData.select(2);

      expect(selectionData.isSelected(2), isTrue);
      expect(selectionData.selectionCount, 1);
      expect(selectionData.getCurrentSelectionIndices(), [2]);
    });

    test('Selecting same index twice does not change count', () {
      selectionData.select(0);
      selectionData.select(0);

      expect(selectionData.selectionCount, 1);
      expect(selectionData.getCurrentSelectionIndices(), [0]);
    });

    test('Cannot exceed maxSelectionCount', () {
      selectionData.select(0);
      selectionData.select(1);
      selectionData.select(2);
      selectionData.select(3);

      expect(selectionData.isSelected(3), isFalse);
      expect(selectionData.selectionCount, 3);
      expect(selectionData.getCurrentSelectionIndices(), [0, 1, 2]);
    });

    test('Allows unlimited selections when maxSelectionCount is null', () {
      final unlimited = SelectionData(size: 5, maxSelectionCount: null);
      unlimited.select(0);
      unlimited.select(1);
      unlimited.select(2);
      unlimited.select(3);
      unlimited.select(4);

      expect(unlimited.selectionCount, 5);
      expect(unlimited.getCurrentSelectionIndices(), [0, 1, 2, 3, 4]);
    });

    test('Silently ignores out-of-bounds indices', () {
      selectionData.select(-1);
      selectionData.select(5);

      expect(selectionData.selectionCount, 0);
    });

    test('Allows new selection after freeing a slot by unselecting', () {
      selectionData.select(0);
      selectionData.select(1);
      selectionData.select(2);
      selectionData.unselect(1);
      selectionData.select(3);

      expect(selectionData.selectionCount, 3);
      expect(selectionData.getCurrentSelectionIndices(), [0, 2, 3]);
    });
  });

  group('unselect', () {
    test('Marks index as unselected and decrements count', () {
      selectionData.select(2);
      selectionData.unselect(2);

      expect(selectionData.isSelected(2), isFalse);
      expect(selectionData.selectionCount, 0);
      expect(selectionData.getCurrentSelectionIndices(), isEmpty);
    });

    test('Is a no-op when index is not selected', () {
      selectionData.unselect(0);

      expect(selectionData.selectionCount, 0);
    });

    test('Silently ignores out-of-bounds indices', () {
      selectionData.unselect(-1);
      selectionData.unselect(5);

      expect(selectionData.selectionCount, 0);
    });
  });

  group('flipSelection', () {
    test('Selects an unselected index', () {
      selectionData.flipSelection(2);

      expect(selectionData.isSelected(2), isTrue);
      expect(selectionData.selectionCount, 1);
    });

    test('Unselects a selected index', () {
      selectionData.select(2);
      selectionData.flipSelection(2);

      expect(selectionData.isSelected(2), isFalse);
      expect(selectionData.selectionCount, 0);
    });

    test('Respects maxSelectionCount when attempting to select', () {
      selectionData.select(0);
      selectionData.select(1);
      selectionData.select(2);
      selectionData.flipSelection(3);

      expect(selectionData.isSelected(3), isFalse);
      expect(selectionData.selectionCount, 3);
    });

    test('Silently ignores out-of-bounds indices', () {
      selectionData.flipSelection(-1);
      selectionData.flipSelection(5);

      expect(selectionData.selectionCount, 0);
    });
  });

  group('isSelected', () {
    test('Returns true for a selected index', () {
      selectionData.select(1);

      expect(selectionData.isSelected(1), isTrue);
    });

    test('Returns false for an unselected index', () {
      expect(selectionData.isSelected(1), isFalse);
    });

    test('Returns false for out-of-bounds indices', () {
      expect(selectionData.isSelected(-1), isFalse);
      expect(selectionData.isSelected(5), isFalse);
    });
  });

  group('getCurrentSelectionIndices', () {
    test('Returns indices in ascending order', () {
      selectionData.select(2);
      selectionData.select(0);
      selectionData.select(4);

      expect(selectionData.getCurrentSelectionIndices(), [0, 2, 4]);
    });

    test('returns empty list when nothing is selected', () {
      expect(selectionData.getCurrentSelectionIndices(), isEmpty);
    });
  });
}
