import 'package:flutter/widgets.dart';
import 'package:selection_group/src/configs/selection_group_layout_config.dart';
import 'package:selection_group/src/models/selection_item_ui_model.dart';
import 'package:selection_group/src/widgets/selection_groups/grid_selection_group.dart';
import 'package:selection_group/src/widgets/selection_groups/list_selection_group.dart';
import 'package:selection_group/src/widgets/selection_groups/wrap_selection_group.dart';

class SelectionGroup<T extends SelectionItemUiModel> extends StatelessWidget {
  final List<T> uiModels;
  final SelectionGroupLayoutConfig layoutConfig;
  final int? maxSelectionCount;
  final List<int> initialSelectionIndices;
  final void Function()? onSelectionOverflow;
  final void Function(List<int> newSelectionIndices) onSelectionChanged;
  final List<Widget> leadingWidgets;
  final List<Widget> trailingWidgets;
  final Widget Function(T model, {required bool selected}) cellBuilder;

  const SelectionGroup({
    super.key,
    required this.uiModels,
    required this.layoutConfig,
    this.maxSelectionCount,
    this.initialSelectionIndices = const [],
    this.onSelectionOverflow,
    required this.onSelectionChanged,
    this.leadingWidgets = const [],
    this.trailingWidgets = const [],
    required this.cellBuilder,
  });

  @override
  Widget build(BuildContext context) {
    switch (layoutConfig) {
      case ListLayoutConfig():
        return ListSelectionGroup(
          uiModels: uiModels,
          layoutConfig: layoutConfig as ListLayoutConfig,
          onSelectionChanged: onSelectionChanged,
          cellBuilder: cellBuilder,
          leadingWidgets: leadingWidgets,
          trailingWidgets: trailingWidgets,
          maxSelectionCount: maxSelectionCount,
          initialSelectionIndices: initialSelectionIndices,
          onSelectionOverflow: onSelectionOverflow,
        );
      case GridLayoutConfig():
        return GridSelectionGroup(
          uiModels: uiModels,
          layoutConfig: layoutConfig as GridLayoutConfig,
          onSelectionChanged: onSelectionChanged,
          cellBuilder: cellBuilder,
          leadingWidgets: leadingWidgets,
          trailingWidgets: trailingWidgets,
          maxSelectionCount: maxSelectionCount,
          initialSelectionIndices: initialSelectionIndices,
          onSelectionOverflow: onSelectionOverflow,
        );
      case WrapLayoutConfig():
        return WrapSelectionGroup(
          uiModels: uiModels,
          layoutConfig: layoutConfig as WrapLayoutConfig,
          onSelectionChanged: onSelectionChanged,
          cellBuilder: cellBuilder,
          leadingWidgets: leadingWidgets,
          trailingWidgets: trailingWidgets,
          maxSelectionCount: maxSelectionCount,
          initialSelectionIndices: initialSelectionIndices,
          onSelectionOverflow: onSelectionOverflow,
        );
    }
  }
}
