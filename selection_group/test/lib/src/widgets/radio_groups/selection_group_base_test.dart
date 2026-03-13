// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:selection_group/selection_group.dart';
import 'package:selection_group/src/widgets/selection_groups/selection_group_base.dart';

class _TestSelectionItemUiModel extends SelectionItemUiModel {
  const _TestSelectionItemUiModel({required super.shouldBeSelected});
}

class _TestRadioGroup
    extends SelectionGroupBase<_TestSelectionItemUiModel, WrapLayoutConfig> {
  const _TestRadioGroup({
    // ignore: unused_element
    super.key,
    required super.uiModels,
    required super.layoutConfig,
    super.maxSelectionCount,
    super.initialSelectionIndices,
    super.onSelectionOverflow,
    required super.onSelectionChanged,
    required super.cellBuilder,
  });

  @override
  Widget buildContentWidget(int itemCount, WrapLayoutConfig layoutConfig,
      Widget Function(int index) cellBuilder) {
    return Column(
      children: List.generate(itemCount, cellBuilder),
    );
  }
}

void main() {
  Widget wrap(Widget child) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: child,
    );
  }

  testWidgets('Initial selection is applied when allowed', (tester) async {
    final models = [
      const _TestSelectionItemUiModel(shouldBeSelected: true),
      const _TestSelectionItemUiModel(shouldBeSelected: true),
      const _TestSelectionItemUiModel(shouldBeSelected: true),
      const _TestSelectionItemUiModel(shouldBeSelected: true),
      const _TestSelectionItemUiModel(shouldBeSelected: true),
    ];

    await tester.pumpWidget(
      wrap(
        _TestRadioGroup(
          uiModels: models,
          layoutConfig: const WrapLayoutConfig(),
          initialSelectionIndices: const [0, 2, 4],
          onSelectionChanged: (_) {},
          cellBuilder: (model, {required selected}) =>
              Text(selected ? 'selected-$model' : 'not-$model'),
        ),
      ),
    );

    expect(find.textContaining('selected'), findsNWidgets(3));
    expect(find.textContaining('not'), findsNWidgets(2));
  });

  testWidgets('Initial selection ignored if model shouldBeSelected is false',
      (tester) async {
    final models = [
      const _TestSelectionItemUiModel(shouldBeSelected: false),
      const _TestSelectionItemUiModel(shouldBeSelected: true),
      const _TestSelectionItemUiModel(shouldBeSelected: false),
      const _TestSelectionItemUiModel(shouldBeSelected: true),
      const _TestSelectionItemUiModel(shouldBeSelected: false),
    ];

    await tester.pumpWidget(
      wrap(
        _TestRadioGroup(
          uiModels: models,
          layoutConfig: const WrapLayoutConfig(),
          initialSelectionIndices: const [0, 2, 4],
          onSelectionChanged: (_) {},
          cellBuilder: (model, {required selected}) =>
              Text(selected ? 'selected' : 'not'),
        ),
      ),
    );

    expect(find.text('selected'), findsNothing);
  });

  testWidgets(
      'Initial selection ignored if the provided initial selection indices are of bounds',
      (tester) async {
    final models = [
      const _TestSelectionItemUiModel(shouldBeSelected: true),
      const _TestSelectionItemUiModel(shouldBeSelected: true),
      const _TestSelectionItemUiModel(shouldBeSelected: true),
    ];

    await tester.pumpWidget(
      wrap(
        _TestRadioGroup(
          uiModels: models,
          layoutConfig: const WrapLayoutConfig(),
          initialSelectionIndices: const [3, 4, 5],
          onSelectionChanged: (_) {},
          cellBuilder: (model, {required selected}) =>
              Text(selected ? 'selected' : 'not'),
        ),
      ),
    );

    expect(find.text('selected'), findsNothing);
  });

  testWidgets('Tap selects item and updates UI', (tester) async {
    final models = [
      const _TestSelectionItemUiModel(shouldBeSelected: true),
      const _TestSelectionItemUiModel(shouldBeSelected: true),
    ];

    await tester.pumpWidget(
      wrap(
        _TestRadioGroup(
          uiModels: models,
          layoutConfig: const WrapLayoutConfig(),
          onSelectionChanged: (_) {},
          cellBuilder: (model, {required selected}) =>
              Text(selected ? 'selected' : 'not'),
        ),
      ),
    );

    await tester.tap(find.text('not').first);
    await tester.pump();

    expect(find.text('selected'), findsOneWidget);
  });

  testWidgets('tap ignored when shouldBeSelected is false', (tester) async {
    final models = [
      const _TestSelectionItemUiModel(shouldBeSelected: false),
    ];

    await tester.pumpWidget(
      wrap(
        _TestRadioGroup(
          uiModels: models,
          layoutConfig: const WrapLayoutConfig(),
          onSelectionChanged: (_) {},
          cellBuilder: (model, {required selected}) =>
              Text(selected ? 'selected' : 'not'),
        ),
      ),
    );

    await tester.tap(find.text('not'));
    await tester.pump();

    expect(find.text('selected'), findsNothing);
  });

  testWidgets('onSelectionChanged triggered after tap', (tester) async {
    final models = [
      const _TestSelectionItemUiModel(shouldBeSelected: true),
    ];

    var selectedIndices = <int>[];

    await tester.pumpWidget(
      wrap(
        _TestRadioGroup(
          uiModels: models,
          layoutConfig: const WrapLayoutConfig(),
          onSelectionChanged: (selectionIndices) {
            selectedIndices = selectionIndices;
          },
          cellBuilder: (model, {required selected}) =>
              Text(selected ? 'selected' : 'not'),
        ),
      ),
    );

    await tester.tap(find.text('not'));
    await tester.pump();

    expect(selectedIndices, isNotEmpty);
  });

  testWidgets('Selection stops at maxSelectionCount and triggers overflow',
      (tester) async {
    final models = [
      const _TestSelectionItemUiModel(shouldBeSelected: true),
      const _TestSelectionItemUiModel(shouldBeSelected: true),
      const _TestSelectionItemUiModel(shouldBeSelected: true),
    ];

    var overflowTriggered = false;
    var selectedIndices = <int>[];

    await tester.pumpWidget(
      wrap(
        _TestRadioGroup(
          uiModels: models,
          layoutConfig: const WrapLayoutConfig(),
          maxSelectionCount: 2,
          onSelectionOverflow: () => overflowTriggered = true,
          onSelectionChanged: (indices) => selectedIndices = indices,
          cellBuilder: (model, {required selected}) =>
              Text(selected ? 'selected' : 'not'),
        ),
      ),
    );

    // Tap first two (select)
    await tester.tap(find.text('not').first);
    await tester.pump();
    await tester.tap(find.text('not').first);
    await tester.pump();
    // Now tapping the 3rd should trigger overflow
    await tester.tap(find.text('not').first);
    await tester.pump();

    // Verify overflow was called
    expect(overflowTriggered, true);

    // Only maxSelectionCount items selected
    expect(selectedIndices.length, 2);
  });

  testWidgets(
      'Initial selection respects maxSelectionCount and does not trigger overflow',
      (tester) async {
    final models = [
      const _TestSelectionItemUiModel(shouldBeSelected: true),
      const _TestSelectionItemUiModel(shouldBeSelected: true),
      const _TestSelectionItemUiModel(shouldBeSelected: true),
    ];

    var overflowTriggered = false;

    await tester.pumpWidget(
      wrap(
        _TestRadioGroup(
          uiModels: models,
          layoutConfig: const WrapLayoutConfig(),
          maxSelectionCount: 2,
          initialSelectionIndices: const [0, 1, 2],
          onSelectionOverflow: () => overflowTriggered = true,
          onSelectionChanged: (_) {},
          cellBuilder: (model, {required selected}) =>
              Text(selected ? 'selected' : 'not'),
        ),
      ),
    );

    // Only the first two should be selected because maxSelectionCount = 2
    expect(find.text('selected'), findsNWidgets(2));
    expect(find.text('not'), findsNWidgets(1));
    // Overflow callback should NOT be called during initialization
    expect(overflowTriggered, isFalse);
  });

  testWidgets('Tapping an already selected item deselects it', (tester) async {
    final models = [
      const _TestSelectionItemUiModel(shouldBeSelected: true),
    ];

    var selectedIndices = <int>[];

    await tester.pumpWidget(
      wrap(
        _TestRadioGroup(
          uiModels: models,
          layoutConfig: const WrapLayoutConfig(),
          onSelectionChanged: (indices) => selectedIndices = indices,
          cellBuilder: (model, {required selected}) =>
              Text(selected ? 'selected' : 'not'),
        ),
      ),
    );

    // Select
    await tester.tap(find.text('not'));
    await tester.pump();

    expect(find.text('selected'), findsOneWidget);

    // Tap again → deselect
    await tester.tap(find.text('selected'));
    await tester.pump();

    expect(find.text('selected'), findsNothing);
    expect(selectedIndices, isEmpty);
  });

  testWidgets(
      'After deselecting, new selections are allowed within maxSelectionCount',
      (tester) async {
    final models = [
      const _TestSelectionItemUiModel(shouldBeSelected: true),
      const _TestSelectionItemUiModel(shouldBeSelected: true),
      const _TestSelectionItemUiModel(shouldBeSelected: true),
    ];

    var selectedIndices = <int>[];

    await tester.pumpWidget(
      wrap(
        _TestRadioGroup(
          uiModels: models,
          layoutConfig: const WrapLayoutConfig(),
          maxSelectionCount: 2,
          onSelectionChanged: (indices) => selectedIndices = indices,
          cellBuilder: (model, {required selected}) =>
              Text(selected ? 'selected' : 'not'),
        ),
      ),
    );

    // Select first two
    await tester.tap(find.text('not').first);
    await tester.pump();
    await tester.tap(find.text('not').first);
    await tester.pump();

    expect(selectedIndices.length, 2);

    // Deselect first
    await tester.tap(find.text('selected').first);
    await tester.pump();

    expect(selectedIndices.length, 1);

    // Now selecting third should succeed
    await tester.tap(find.text('not').first);
    await tester.pump();

    expect(selectedIndices.length, 2);
  });
}
