// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:selection_group/selection_group.dart';
import 'package:selection_group/src/widgets/selection_groups/grid_selection_group.dart';

class _TestSelectionItemUiModel extends SelectionItemUiModel {
  _TestSelectionItemUiModel() : super(shouldBeSelected: true);
}

void main() {
  setUpAll(() {
    registerFallbackValue(_TestSelectionItemUiModel());
  });

  List<SelectionItemUiModel> createModels(int count) {
    return List.generate(count, (_) => _TestSelectionItemUiModel());
  }

  Widget createTestWidget({
    required List<SelectionItemUiModel> models,
    required GridLayoutConfig layoutConfig,
    required Widget Function(SelectionItemUiModel model,
            {required bool selected})
        cellBuilder,
    required void Function(List<int> selectedIndices) onSelectionChanged,
    List<Widget> leading = const [],
    List<Widget> trailing = const [],
  }) {
    return MaterialApp(
      home: Scaffold(
        body: GridSelectionGroup<SelectionItemUiModel>(
          uiModels: models,
          layoutConfig: layoutConfig,
          onSelectionChanged: onSelectionChanged,
          leadingWidgets: leading,
          trailingWidgets: trailing,
          cellBuilder: cellBuilder,
        ),
      ),
    );
  }

  testWidgets('Renders GridView with correct configuration', (tester) async {
    const layoutConfig = GridLayoutConfig(
      axis: Axis.horizontal,
      crossAxisItemCount: 2,
      verticalSpacing: 8,
      horizontalSpacing: 6,
      padding: EdgeInsets.all(12),
      shrinkWrap: false,
      physics: AlwaysScrollableScrollPhysics(),
    );

    await tester.pumpWidget(
      createTestWidget(
        models: createModels(2),
        layoutConfig: layoutConfig,
        cellBuilder: (_, {required selected}) => const SizedBox(),
        onSelectionChanged: (_) {},
      ),
    );

    final gridView = tester.widget<GridView>(find.byType(GridView));
    expect(gridView.shrinkWrap, layoutConfig.shrinkWrap);
    expect(gridView.padding, layoutConfig.padding);
    expect(gridView.physics, layoutConfig.physics);
    expect(gridView.scrollDirection, layoutConfig.axis);
    expect(
        gridView.gridDelegate,
        isA<SliverGridDelegateWithFixedCrossAxisCount>().having(
            (p) => p.crossAxisCount,
            'crossAxisCount',
            layoutConfig.crossAxisItemCount));
  });

  testWidgets('Vertical axis spacing mapping is correct', (tester) async {
    const layoutConfig = GridLayoutConfig(
      axis: Axis.vertical,
      verticalSpacing: 8,
      horizontalSpacing: 6,
    );

    await tester.pumpWidget(
      createTestWidget(
        models: createModels(2),
        layoutConfig: layoutConfig,
        cellBuilder: (_, {required selected}) => const SizedBox(),
        onSelectionChanged: (_) {},
      ),
    );

    final gridView = tester.widget<GridView>(find.byType(GridView));
    expect(
        gridView.gridDelegate,
        isA<SliverGridDelegateWithFixedCrossAxisCount>()
            .having((p) => p.mainAxisSpacing, 'mainAxisSpacing',
                layoutConfig.verticalSpacing)
            .having((p) => p.crossAxisSpacing, 'crossAxisSpacing',
                layoutConfig.horizontalSpacing));
  });

  testWidgets('Horizontal axis spacing mapping is correct', (tester) async {
    const layoutConfig = GridLayoutConfig(
      axis: Axis.horizontal,
      verticalSpacing: 8,
      horizontalSpacing: 6,
    );

    await tester.pumpWidget(
      createTestWidget(
        models: createModels(2),
        layoutConfig: layoutConfig,
        cellBuilder: (_, {required selected}) => const SizedBox(),
        onSelectionChanged: (_) {},
      ),
    );

    final gridView = tester.widget<GridView>(find.byType(GridView));
    expect(
        gridView.gridDelegate,
        isA<SliverGridDelegateWithFixedCrossAxisCount>()
            .having((p) => p.mainAxisSpacing, 'mainAxisSpacing',
                layoutConfig.horizontalSpacing)
            .having((p) => p.crossAxisSpacing, 'crossAxisSpacing',
                layoutConfig.verticalSpacing));
  });

  testWidgets('Computes correct total item count', (tester) async {
    const layout = GridLayoutConfig();
    await tester.pumpWidget(
      createTestWidget(
        models: createModels(3),
        layoutConfig: layout,
        cellBuilder: (_, {required selected}) => const SizedBox(),
        onSelectionChanged: (_) {},
        leading: const [Text('L1'), Text('L2')],
        trailing: const [Text('T1'), Text('T2')],
      ),
    );

    final gridView = tester.widget<GridView>(find.byType(GridView));
    expect(gridView.semanticChildCount, 7);
  });

  testWidgets('The cellBuilder invoked only for selection items',
      (tester) async {
    const layoutConfig = GridLayoutConfig();
    var calls = 0;

    await tester.pumpWidget(
      createTestWidget(
        models: createModels(3),
        layoutConfig: layoutConfig,
        cellBuilder: (_, {required selected}) {
          calls++;
          return const SizedBox();
        },
        onSelectionChanged: (_) {},
        leading: const [Text('L')],
        trailing: const [Text('T')],
      ),
    );

    expect(calls, 3);
  });
}
