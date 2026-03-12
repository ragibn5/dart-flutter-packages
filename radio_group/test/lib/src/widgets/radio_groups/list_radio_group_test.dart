// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_group/src/configs/radio_group_layout_config.dart';
import 'package:radio_group/src/models/radio_item_ui_model.dart';
import 'package:radio_group/src/widgets/radio_groups/list_radio_group.dart';

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
    required ListLayoutConfig layoutConfig,
    required Widget Function(RadioItemUiModel model, {required bool selected})
        cellBuilder,
    required void Function(RadioItemUiModel model) onSelectionChanged,
    List<Widget> leading = const [],
    List<Widget> trailing = const [],
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ListRadioGroup<RadioItemUiModel>(
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

  testWidgets('The cellBuilder invoked only for radio items', (tester) async {
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
