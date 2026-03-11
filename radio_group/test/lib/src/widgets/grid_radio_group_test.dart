// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_group/src/configs/radio_group_layout_config.dart';
import 'package:radio_group/src/models/radio_item_ui_model.dart';
import 'package:radio_group/src/widgets/grid_radio_group.dart';

class _TestRadioItemUiModel extends RadioItemUiModel {
  _TestRadioItemUiModel() : super(shouldBeSelected: true);
}

void main() {
  setUpAll(() {
    registerFallbackValue(_TestRadioItemUiModel());
  });

  setUp(() {});

  List<RadioItemUiModel> createModels(int count) {
    return List.generate(count, (_) => _TestRadioItemUiModel());
  }

  Widget createTestWidget({
    required List<RadioItemUiModel> models,
    required GridLayoutConfig layoutConfig,
    required Widget Function(RadioItemUiModel model, {required bool selected})
        cellBuilder,
    required void Function(RadioItemUiModel model) onSelectionChanged,
    List<Widget> leading = const [],
    List<Widget> trailing = const [],
  }) {
    return MaterialApp(
      home: Scaffold(
        body: GridRadioGroup<RadioItemUiModel>(
          uiModels: models,
          layoutConfig: layoutConfig,
          cellBuilder: cellBuilder,
          onSelectionChanged: onSelectionChanged,
          leadingWidgets: leading,
          trailingWidgets: trailing,
        ),
      ),
    );
  }

  testWidgets('Renders GridView with correct configuration', (tester) async {
    const layoutConfig = GridLayoutConfig(
      crossAxisItemCount: 2,
      verticalSpacing: 8,
      horizontalSpacing: 6,
      axis: Axis.horizontal,
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
      verticalSpacing: 8,
      horizontalSpacing: 6,
      axis: Axis.vertical,
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
      verticalSpacing: 8,
      horizontalSpacing: 6,
      axis: Axis.horizontal,
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

  testWidgets('The cellBuilder invoked only for radio items', (tester) async {
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
