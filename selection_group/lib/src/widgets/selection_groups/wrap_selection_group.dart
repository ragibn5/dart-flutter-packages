import 'package:flutter/widgets.dart';
import 'package:selection_group/src/configs/selection_group_layout_config.dart';
import 'package:selection_group/src/models/selection_item_ui_model.dart';
import 'package:selection_group/src/widgets/selection_groups/selection_group_base.dart';
import 'package:selection_group/src/widgets/builders/leading_trailing_aware_child_builders.dart';

class WrapSelectionGroup<T extends SelectionItemUiModel>
    extends SelectionGroupBase<T, WrapLayoutConfig> {
  final List<Widget> _leadingWidgets;
  final List<Widget> _trailingWidgets;

  const WrapSelectionGroup({
    super.key,
    required super.uiModels,
    required super.layoutConfig,
    required super.cellBuilder,
    required super.onSelectionChanged,
    super.maxSelectionCount,
    super.initialSelectionIndices,
    super.onSelectionOverflow,
    List<Widget> leadingWidgets = const [],
    List<Widget> trailingWidgets = const [],
  })  : _leadingWidgets = leadingWidgets,
        _trailingWidgets = trailingWidgets;

  @override
  Widget buildContentWidget(
    int itemCount,
    WrapLayoutConfig layoutConfig,
    Widget Function(int index) cellBuilder,
  ) {
    final children = <Widget>[];
    final totalChildrenCount =
        itemCount + _leadingWidgets.length + _trailingWidgets.length;

    for (var i = 0; i < totalChildrenCount; i++) {
      children.add(
        LeadingTrailingAwareChildBuilder(
          index: i,
          itemCount: itemCount,
          builder: cellBuilder,
          leadingWidgets: _leadingWidgets,
          trailingWidgets: _trailingWidgets,
        ),
      );
    }

    return Wrap(
      direction: layoutConfig.axis,
      spacing: layoutConfig.spacing,
      runSpacing: layoutConfig.runSpacing,
      children: children,
    );
  }
}
