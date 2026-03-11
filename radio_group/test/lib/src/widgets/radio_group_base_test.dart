// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_group/src/configs/radio_group_layout_config.dart';
import 'package:radio_group/src/models/radio_item_ui_model.dart';
import 'package:radio_group/src/widgets/radio_group_base.dart';

class _TestRadioItemUiModel extends RadioItemUiModel {
  const _TestRadioItemUiModel({required super.shouldBeSelected});
}

class _TestRadioGroup
    extends RadioGroupBase<_TestRadioItemUiModel, WrapLayoutConfig> {
  const _TestRadioGroup({
    super.key,
    required super.uiModels,
    required super.layoutConfig,
    required super.cellBuilder,
    required super.onSelectionChanged,
    super.initialSelectionIndex,
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
      const _TestRadioItemUiModel(shouldBeSelected: true),
      const _TestRadioItemUiModel(shouldBeSelected: true),
    ];

    await tester.pumpWidget(
      wrap(
        _TestRadioGroup(
          uiModels: models,
          layoutConfig: const WrapLayoutConfig(),
          initialSelectionIndex: 1,
          onSelectionChanged: (_) {},
          cellBuilder: (model, {required selected}) =>
              Text(selected ? 'selected-$model' : 'not-$model'),
        ),
      ),
    );

    expect(find.textContaining('not'), findsOneWidget);
  });

  testWidgets('Initial selection ignored if model shouldBeSelected is false',
      (tester) async {
    final models = [
      const _TestRadioItemUiModel(shouldBeSelected: false),
    ];

    await tester.pumpWidget(
      wrap(
        _TestRadioGroup(
          uiModels: models,
          layoutConfig: const WrapLayoutConfig(),
          initialSelectionIndex: 0,
          onSelectionChanged: (_) {},
          cellBuilder: (model, {required selected}) =>
              Text(selected ? 'selected' : 'not'),
        ),
      ),
    );

    expect(find.text('selected'), findsNothing);
  });

  testWidgets(
      'Initial selection ignored if model the provided initial selection index out of bounds',
      (tester) async {
    final models = [
      const _TestRadioItemUiModel(shouldBeSelected: false),
    ];

    await tester.pumpWidget(
      wrap(
        _TestRadioGroup(
          uiModels: models,
          layoutConfig: const WrapLayoutConfig(),
          initialSelectionIndex: 5,
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
      const _TestRadioItemUiModel(shouldBeSelected: true),
      const _TestRadioItemUiModel(shouldBeSelected: true),
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
      const _TestRadioItemUiModel(shouldBeSelected: false),
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
      const _TestRadioItemUiModel(shouldBeSelected: true),
    ];

    _TestRadioItemUiModel? selected;

    await tester.pumpWidget(
      wrap(
        _TestRadioGroup(
          uiModels: models,
          layoutConfig: const WrapLayoutConfig(),
          onSelectionChanged: (model) {
            selected = model;
          },
          cellBuilder: (model, {required selected}) =>
              Text(selected ? 'selected' : 'not'),
        ),
      ),
    );

    await tester.tap(find.text('not'));
    await tester.pump();
    await tester.pump();

    expect(selected, models.first);
  });
}
