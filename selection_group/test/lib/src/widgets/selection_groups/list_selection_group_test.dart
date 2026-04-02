// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:selection_group/selection_group.dart';
import 'package:selection_group/src/widgets/selection_groups/list_selection_group.dart';

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
    required ListLayoutConfig layoutConfig,
    int? maxSelectionCount,
    List<int> initialSelectionIndices = const [],
    void Function()? onSelectionOverflow,
    required void Function(List<int> selectedIndices) onSelectionChanged,
    List<Widget> leading = const [],
    List<Widget> trailing = const [],
    required Widget Function(SelectionItemUiModel model,
            {required bool selected})
        cellBuilder,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ListSelectionGroup<SelectionItemUiModel>(
          uiModels: models,
          layoutConfig: layoutConfig,
          maxSelectionCount: maxSelectionCount,
          initialSelectionIndices: initialSelectionIndices,
          onSelectionOverflow: onSelectionOverflow,
          onSelectionChanged: onSelectionChanged,
          leadingWidgets: leading,
          trailingWidgets: trailing,
          cellBuilder: cellBuilder,
        ),
      ),
    );
  }

  testWidgets('Renders ListView with correct configuration', (tester) async {
    const layoutConfig = ListLayoutConfig(
      axis: Axis.horizontal,
      spacing: 8,
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

    final listView = tester.widget<ListView>(find.byType(ListView));
    expect(listView.shrinkWrap, layoutConfig.shrinkWrap);
    expect(listView.padding, layoutConfig.padding);
    expect(listView.physics, layoutConfig.physics);
    expect(listView.scrollDirection, layoutConfig.axis);
  });

  testWidgets('Computes correct total item count', (tester) async {
    const layout = ListLayoutConfig();
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

    final listView = tester.widget<ListView>(find.byType(ListView));
    expect(listView.semanticChildCount, 7);
  });

  testWidgets('The cellBuilder invoked only for selection items',
      (tester) async {
    const layoutConfig = ListLayoutConfig();
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
