import 'package:flutter/widgets.dart';
import 'package:radio_group/src/configs/radio_group_layout_config.dart';
import 'package:radio_group/src/models/radio_item_ui_model.dart';
import 'package:radio_group/src/widgets/grid_radio_group.dart';
import 'package:radio_group/src/widgets/list_radio_group.dart';
import 'package:radio_group/src/widgets/wrap_radio_group.dart';

class RadioGroup<T extends RadioItemUiModel> extends StatelessWidget {
  final List<T> _uiModels;
  final RadioGroupLayoutConfig _layoutConfig;
  final Widget Function(T model, {required bool selected}) _cellBuilder;
  final void Function(T selectedModel) _onSelectionChanged;

  final int? _initialSelectionIndex;
  final List<Widget> _leadingWidgets;
  final List<Widget> _trailingWidgets;

  const RadioGroup({
    super.key,
    required List<T> uiModels,
    required RadioGroupLayoutConfig layoutConfig,
    required Widget Function(T model, {required bool selected}) cellBuilder,
    required void Function(T selectedModel) onSelectionChanged,
    int? initialSelectionIndex,
    List<Widget> leadingWidgets = const [],
    List<Widget> trailingWidgets = const [],
  })  : _uiModels = uiModels,
        _layoutConfig = layoutConfig,
        _cellBuilder = cellBuilder,
        _onSelectionChanged = onSelectionChanged,
        _initialSelectionIndex = initialSelectionIndex,
        _leadingWidgets = leadingWidgets,
        _trailingWidgets = trailingWidgets;

  @override
  Widget build(BuildContext context) {
    switch (_layoutConfig) {
      case ListLayoutConfig():
        return ListRadioGroup(
          uiModels: _uiModels,
          layoutConfig: _layoutConfig as ListLayoutConfig,
          onSelectionChanged: _onSelectionChanged,
          cellBuilder: _cellBuilder,
          initialSelectionIndex: _initialSelectionIndex,
          leadingWidgets: _leadingWidgets,
          trailingWidgets: _trailingWidgets,
        );
      case GridLayoutConfig():
        return GridRadioGroup(
          uiModels: _uiModels,
          layoutConfig: _layoutConfig as GridLayoutConfig,
          onSelectionChanged: _onSelectionChanged,
          cellBuilder: _cellBuilder,
          initialSelectionIndex: _initialSelectionIndex,
          leadingWidgets: _leadingWidgets,
          trailingWidgets: _trailingWidgets,
        );
      case WrapLayoutConfig():
        return WrapRadioGroup(
          uiModels: _uiModels,
          layoutConfig: _layoutConfig as WrapLayoutConfig,
          onSelectionChanged: _onSelectionChanged,
          cellBuilder: _cellBuilder,
          initialSelectionIndex: _initialSelectionIndex,
          leadingWidgets: _leadingWidgets,
          trailingWidgets: _trailingWidgets,
        );
    }
  }
}
