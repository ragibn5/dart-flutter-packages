// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_group/src/configs/radio_group_layout_config.dart';
import 'package:radio_group/src/models/radio_item_ui_model.dart';
import 'package:radio_group/src/radio_groups/list_radio_group.dart';
import 'package:radio_group/src/radio_groups/wrap_radio_group.dart';

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
    required WrapLayoutConfig layoutConfig,
    required Widget Function(RadioItemUiModel model, {required bool selected})
        cellBuilder,
    required void Function(RadioItemUiModel model) onSelectionChanged,
    List<Widget> leading = const [],
    List<Widget> trailing = const [],
  }) {
    return MaterialApp(
      home: Scaffold(
        body: WrapRadioGroup<RadioItemUiModel>(
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

  testWidgets('Renders Wrap with correct configuration', (tester) async {
    const layoutConfig = WrapLayoutConfig(
      axis: Axis.horizontal,
      spacing: 8,
      runSpacing: 16,
    );

    await tester.pumpWidget(
      createTestWidget(
        models: createModels(2),
        layoutConfig: layoutConfig,
        cellBuilder: (_, {required selected}) => const SizedBox(),
        onSelectionChanged: (_) {},
      ),
    );

    final wrapView = tester.widget<Wrap>(find.byType(Wrap));
    expect(wrapView.direction, layoutConfig.axis);
    expect(wrapView.spacing, layoutConfig.spacing);
    expect(wrapView.runSpacing, layoutConfig.runSpacing);
  });

  testWidgets('Computes correct total item count', (tester) async {
    const layout = WrapLayoutConfig();
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

    final wrapView = tester.widget<Wrap>(find.byType(Wrap));
    expect(wrapView.children.length, 7);
  });

  testWidgets('The cellBuilder invoked only for radio items', (tester) async {
    const layoutConfig = WrapLayoutConfig();
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
