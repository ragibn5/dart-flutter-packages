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

  test('Initial state', () {
    // Verify initial state
    expect(selectionData.selectionCount, 0);
    expect(selectionData.getCurrentSelectionIndices(), isEmpty);
    expect(selectionData.maxSelectionCount, 3);
  });

  test('Select an index', () {
    // Select index 2
    selectionData.select(2);

    // Verify selection
    expect(selectionData.isSelected(2), isTrue);
    expect(selectionData.selectionCount, 1);
    expect(selectionData.getCurrentSelectionIndices(), [2]);
  });

  test('Unselect an index', () {
    // Select index 2 and then unselect it
    selectionData.select(2);
    selectionData.unselect(2);

    // Verify un-selection
    expect(selectionData.isSelected(2), isFalse);
    expect(selectionData.selectionCount, 0);
    expect(selectionData.getCurrentSelectionIndices(), isEmpty);
  });

  test('Flip selection', () {
    // Flip selection for index 2 (select)
    selectionData.flipSelection(2);
    expect(selectionData.isSelected(2), isTrue);
    expect(selectionData.selectionCount, 1);
    expect(selectionData.getCurrentSelectionIndices(), [2]);

    // Flip selection for index 2 again (unselect)
    selectionData.flipSelection(2);
    expect(selectionData.isSelected(2), isFalse);
    expect(selectionData.selectionCount, 0);
    expect(selectionData.getCurrentSelectionIndices(), isEmpty);
  });

  test('Select multiple indices', () {
    // Select indices 0, 1, and 2
    selectionData.select(0);
    selectionData.select(1);
    selectionData.select(2);

    // Verify selections
    expect(selectionData.selectionCount, 3);
    expect(selectionData.getCurrentSelectionIndices(), [0, 1, 2]);
  });

  test('Cannot exceed maxSelectionCount', () {
    // Select indices 0, 1, and 2 (max limit)
    selectionData.select(0);
    selectionData.select(1);
    selectionData.select(2);

    // Attempt to select index 3 (should fail)
    selectionData.select(3);
    expect(selectionData.isSelected(3), isFalse);
    expect(selectionData.selectionCount, 3);
    expect(selectionData.getCurrentSelectionIndices(), [0, 1, 2]);
  });

  test('Unselect after reaching maxSelectionCount', () {
    // Select indices 0, 1, and 2 (max limit)
    selectionData.select(0);
    selectionData.select(1);
    selectionData.select(2);

    // Unselect index 1
    selectionData.unselect(1);

    // Verify un-selection
    expect(selectionData.isSelected(1), isFalse);
    expect(selectionData.selectionCount, 2);
    expect(selectionData.getCurrentSelectionIndices(), [0, 2]);

    // Now select index 3 (should succeed)
    selectionData.select(3);
    expect(selectionData.isSelected(3), isTrue);
    expect(selectionData.selectionCount, 3);
    expect(selectionData.getCurrentSelectionIndices(), [0, 2, 3]);
  });

  test('Edge case: No maxSelectionCount', () {
    // Create a SelectionData instance with no maxSelectionCount
    final unlimitedSelectionData = SelectionData(
      size: 3,
      maxSelectionCount: null,
    );

    // Select all indices
    unlimitedSelectionData.select(0);
    unlimitedSelectionData.select(1);
    unlimitedSelectionData.select(2);

    // Verify all indices are selected
    expect(unlimitedSelectionData.selectionCount, 3);
    expect(unlimitedSelectionData.getCurrentSelectionIndices(), [0, 1, 2]);
  });

  test('Edge case: Invalid index throws assertion', () {
    // Attempt to select an invalid index
    expect(() => selectionData.select(5), throwsA(isA<AssertionError>()));
    expect(() => selectionData.unselect(-1), throwsA(isA<AssertionError>()));
    expect(
      () => selectionData.flipSelection(10),
      throwsA(isA<AssertionError>()),
    );
  });

  test('Edge case: Unselect when no selections exist', () {
    // Attempt to unselect an index when no selections exist
    selectionData.unselect(0);

    // Verify no changes
    expect(selectionData.selectionCount, 0);
    expect(selectionData.getCurrentSelectionIndices(), isEmpty);
  });
}
