import 'package:flutter/widgets.dart';
import 'package:selection_group/src/configs/selection_group_layout_config.dart';
import 'package:selection_group/src/models/selection_item_ui_model.dart';
import 'package:selection_group/src/widgets/builders/leading_trailing_aware_child_builder.dart';
import 'package:selection_group/src/widgets/selection_groups/selection_group_base.dart';

class GridSelectionGroup<T extends SelectionItemUiModel>
    extends SelectionGroupBase<T, GridLayoutConfig> {
  final List<Widget> leadingWidgets;
  final List<Widget> trailingWidgets;

  const GridSelectionGroup({
    super.key,
    required super.uiModels,
    required super.layoutConfig,
    super.maxSelectionCount,
    super.initialSelectionIndices,
    super.onSelectionOverflow,
    required super.onSelectionChanged,
    this.leadingWidgets = const [],
    this.trailingWidgets = const [],
    required super.cellBuilder,
  });

  @override
  Widget buildContentWidget(
    int itemCount,
    GridLayoutConfig layoutConfig,
    Widget Function(int index) cellBuilder,
  ) {
    return GridView.builder(
      shrinkWrap: layoutConfig.shrinkWrap,
      padding: layoutConfig.padding,
      physics: layoutConfig.physics,
      scrollDirection: layoutConfig.axis,
      itemCount: itemCount + leadingWidgets.length + trailingWidgets.length,
      itemBuilder: (context, index) => LeadingTrailingAwareChildBuilder(
        index: index,
        itemCount: itemCount,
        builder: cellBuilder,
        leadingWidgets: leadingWidgets,
        trailingWidgets: trailingWidgets,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: layoutConfig.crossAxisItemCount,
        mainAxisSpacing: layoutConfig.verticalSpacing,
        crossAxisSpacing: layoutConfig.horizontalSpacing,
      ),
    );
  }
}
