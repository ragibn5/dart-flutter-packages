import 'package:flutter/widgets.dart';
import 'package:selection_group/src/configs/selection_group_layout_config.dart';
import 'package:selection_group/src/models/selection_item_ui_model.dart';
import 'package:selection_group/src/selection_groups/selection_group_base.dart';
import 'package:selection_group/src/widgets/leading_trailing_aware_child.dart';

class GridSelectionGroup<T extends SelectionItemUiModel>
    extends SelectionGroupBase<T, GridSelectionGroupLayoutConfig> {
  final List<Widget> _leadingWidgets;
  final List<Widget> _trailingWidgets;

  const GridSelectionGroup({
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
    GridSelectionGroupLayoutConfig layoutConfig,
    Widget Function(int index) cellBuilder,
  ) {
    return GridView.builder(
      shrinkWrap: layoutConfig.shrinkWrap,
      padding: layoutConfig.padding,
      physics: layoutConfig.physics,
      scrollDirection: layoutConfig.axis,
      itemCount: itemCount + _leadingWidgets.length + _trailingWidgets.length,
      itemBuilder: (context, index) => LeadingTrailingAwareChildBuilder(
        index: index,
        itemCount: itemCount,
        builder: cellBuilder,
        leadingWidgets: _leadingWidgets,
        trailingWidgets: _trailingWidgets,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: layoutConfig.crossAxisItemCount,
        mainAxisSpacing: layoutConfig.verticalSpacing,
        crossAxisSpacing: layoutConfig.horizontalSpacing,
      ),
    );
  }
}
