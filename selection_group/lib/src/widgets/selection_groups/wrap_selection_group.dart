import 'package:flutter/widgets.dart';
import 'package:selection_group/src/configs/selection_group_layout_config.dart';
import 'package:selection_group/src/models/selection_item_ui_model.dart';
import 'package:selection_group/src/widgets/builders/leading_trailing_aware_child_builder.dart';
import 'package:selection_group/src/widgets/selection_groups/selection_group_base.dart';

class WrapSelectionGroup<T extends SelectionItemUiModel>
    extends SelectionGroupBase<T, WrapLayoutConfig> {
  final List<Widget> leadingWidgets;
  final List<Widget> trailingWidgets;

  const WrapSelectionGroup({
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
    WrapLayoutConfig layoutConfig,
    Widget Function(int index) cellBuilder,
  ) {
    final children = <Widget>[];
    final totalChildrenCount =
        itemCount + leadingWidgets.length + trailingWidgets.length;

    for (var i = 0; i < totalChildrenCount; i++) {
      children.add(
        LeadingTrailingAwareChildBuilder(
          index: i,
          itemCount: itemCount,
          builder: cellBuilder,
          leadingWidgets: leadingWidgets,
          trailingWidgets: trailingWidgets,
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
