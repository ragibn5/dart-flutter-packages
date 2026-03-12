// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_group/radio_group.dart';
import 'package:radio_group/src/widgets/radio_groups/grid_radio_group.dart';
import 'package:radio_group/src/widgets/radio_groups/list_radio_group.dart';
import 'package:radio_group/src/widgets/radio_groups/wrap_radio_group.dart';

class _TestModel extends RadioItemUiModel {
  const _TestModel();
}

void main() {
  final testModels = List.generate(3, (_) => const _TestModel());

  Widget wrap(Widget child) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: child,
    );
  }

  testWidgets(
      'RadioGroup delegates to ListRadioGroup when layout config is a ListLayoutConfig',
      (tester) async {
    const layoutConfig = ListLayoutConfig();
    await tester.pumpWidget(
      wrap(
        RadioGroup<_TestModel>(
          uiModels: testModels,
          layoutConfig: layoutConfig,
          cellBuilder: (model, {required selected}) => const SizedBox(),
          onSelectionChanged: (_) {},
        ),
      ),
    );

    expect(find.byType(ListRadioGroup<_TestModel>), findsOneWidget);
    expect(find.byType(GridRadioGroup<_TestModel>), findsNothing);
    expect(find.byType(WrapRadioGroup<_TestModel>), findsNothing);
  });

  testWidgets(
      'RadioGroup delegates to GridRadioGroup when layout config is a GridLayoutConfig',
      (tester) async {
    const layoutConfig = GridLayoutConfig();
    await tester.pumpWidget(
      wrap(
        RadioGroup<_TestModel>(
          uiModels: testModels,
          layoutConfig: layoutConfig,
          cellBuilder: (model, {required selected}) => const SizedBox(),
          onSelectionChanged: (_) {},
        ),
      ),
    );

    expect(find.byType(GridRadioGroup<_TestModel>), findsOneWidget);
    expect(find.byType(ListRadioGroup<_TestModel>), findsNothing);
    expect(find.byType(WrapRadioGroup<_TestModel>), findsNothing);
  });

  testWidgets(
      'RadioGroup delegates to WrapRadioGroup when layout config is a WrapLayoutConfig',
      (tester) async {
    const layoutConfig = WrapLayoutConfig();
    await tester.pumpWidget(
      wrap(
        RadioGroup<_TestModel>(
          uiModels: testModels,
          layoutConfig: layoutConfig,
          cellBuilder: (model, {required selected}) => const SizedBox(),
          onSelectionChanged: (_) {},
        ),
      ),
    );

    expect(find.byType(WrapRadioGroup<_TestModel>), findsOneWidget);
    expect(find.byType(ListRadioGroup<_TestModel>), findsNothing);
    expect(find.byType(GridRadioGroup<_TestModel>), findsNothing);
  });
}
