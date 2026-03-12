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
  Widget wrap(Widget child) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: child,
    );
  }

  final testModels = List.generate(3, (_) => const _TestModel());

  testWidgets(
      'RadioGroup delegates to ListRadioGroup when layout is ListLayoutConfig',
      (tester) async {
    const layout = ListLayoutConfig();
    await tester.pumpWidget(
      wrap(
        RadioGroup<_TestModel>(
          uiModels: testModels,
          layoutConfig: layout,
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
      'RadioGroup delegates to GridRadioGroup when layout is GridLayoutConfig',
      (tester) async {
    const layout = GridLayoutConfig();
    await tester.pumpWidget(
      wrap(
        RadioGroup<_TestModel>(
          uiModels: testModels,
          layoutConfig: layout,
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
      'RadioGroup delegates to WrapRadioGroup when layout is WrapLayoutConfig',
      (tester) async {
    const layout = WrapLayoutConfig();
    await tester.pumpWidget(
      wrap(
        RadioGroup<_TestModel>(
          uiModels: testModels,
          layoutConfig: layout,
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
