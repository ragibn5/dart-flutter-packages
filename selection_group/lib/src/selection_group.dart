import 'package:flutter/widgets.dart';
import 'package:selection_group/src/configs/selection_group_layout_config.dart';
import 'package:selection_group/src/models/selection_item_ui_model.dart';
import 'package:selection_group/src/widgets/selection_groups/grid_selection_group.dart';
import 'package:selection_group/src/widgets/selection_groups/list_selection_group.dart';
import 'package:selection_group/src/widgets/selection_groups/wrap_selection_group.dart';

class SelectionGroup<T extends SelectionItemUiModel> extends StatelessWidget {
  final List<T> _uiModels;
  final SelectionGroupLayoutConfig _layoutConfig;
  final Widget Function(T model, {required bool selected}) _cellBuilder;
  final void Function(List<int> newSelectionIndices) _onSelectionChanged;

  final int? _maxSelectionCount;
  final List<int> _initialSelectionIndices;
  final List<Widget> _leadingWidgets;
  final List<Widget> _trailingWidgets;
  final void Function()? _onSelectionOverflow;

  const SelectionGroup({
    super.key,
    required List<T> uiModels,
    required SelectionGroupLayoutConfig layoutConfig,
    required Widget Function(T model, {required bool selected}) cellBuilder,
    required void Function(List<int> newSelectionIndices) onSelectionChanged,
    int? maxSelectionCount,
    List<int> initialSelectionIndices = const [],
    void Function()? onSelectionOverflow,
    List<Widget> leadingWidgets = const [],
    List<Widget> trailingWidgets = const [],
  })  : _uiModels = uiModels,
        _layoutConfig = layoutConfig,
        _cellBuilder = cellBuilder,
        _onSelectionChanged = onSelectionChanged,
        _maxSelectionCount = maxSelectionCount,
        _initialSelectionIndices = initialSelectionIndices,
        _onSelectionOverflow = onSelectionOverflow,
        _leadingWidgets = leadingWidgets,
        _trailingWidgets = trailingWidgets;

  @override
  Widget build(BuildContext context) {
    switch (_layoutConfig) {
      case ListLayoutConfig():
        return ListSelectionGroup(
          uiModels: _uiModels,
          layoutConfig: _layoutConfig as ListLayoutConfig,
          onSelectionChanged: _onSelectionChanged,
          cellBuilder: _cellBuilder,
          leadingWidgets: _leadingWidgets,
          trailingWidgets: _trailingWidgets,
          maxSelectionCount: _maxSelectionCount,
          initialSelectionIndices: _initialSelectionIndices,
          onSelectionOverflow: _onSelectionOverflow,
        );
      case GridLayoutConfig():
        return GridSelectionGroup(
          uiModels: _uiModels,
          layoutConfig: _layoutConfig as GridLayoutConfig,
          onSelectionChanged: _onSelectionChanged,
          cellBuilder: _cellBuilder,
          leadingWidgets: _leadingWidgets,
          trailingWidgets: _trailingWidgets,
          maxSelectionCount: _maxSelectionCount,
          initialSelectionIndices: _initialSelectionIndices,
          onSelectionOverflow: _onSelectionOverflow,
        );
      case WrapLayoutConfig():
        return WrapSelectionGroup(
          uiModels: _uiModels,
          layoutConfig: _layoutConfig as WrapLayoutConfig,
          onSelectionChanged: _onSelectionChanged,
          cellBuilder: _cellBuilder,
          leadingWidgets: _leadingWidgets,
          trailingWidgets: _trailingWidgets,
          maxSelectionCount: _maxSelectionCount,
          initialSelectionIndices: _initialSelectionIndices,
          onSelectionOverflow: _onSelectionOverflow,
        );
    }
  }
}
