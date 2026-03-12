import 'package:flutter/widgets.dart';
import 'package:radio_group/src/configs/radio_group_layout_config.dart';
import 'package:radio_group/src/models/radio_item_ui_model.dart';
import 'package:radio_group/src/widgets/builders/leading_trailing_aware_child_builder.dart';
import 'package:radio_group/src/widgets/radio_groups/radio_group_base.dart';

class ListRadioGroup<T extends RadioItemUiModel>
    extends RadioGroupBase<T, ListLayoutConfig> {
  final List<Widget> leadingWidgets;
  final List<Widget> trailingWidgets;

  const ListRadioGroup({
    super.key,
    required super.uiModels,
    required super.layoutConfig,
    required super.cellBuilder,
    required super.onSelectionChanged,
    super.initialSelectionIndex,
    this.leadingWidgets = const [],
    this.trailingWidgets = const [],
  });

  @override
  Widget buildContentWidget(
    int itemCount,
    ListLayoutConfig layoutConfig,
    Widget Function(int index) cellBuilder,
  ) {
    return ListView.separated(
      shrinkWrap: layoutConfig.shrinkWrap,
      padding: layoutConfig.padding,
      physics: layoutConfig.physics,
      scrollDirection: layoutConfig.axis,
      itemCount: itemCount + leadingWidgets.length + trailingWidgets.length,
      separatorBuilder: (context, index) => switch (layoutConfig.axis) {
        Axis.horizontal => SizedBox(width: layoutConfig.spacing),
        Axis.vertical => SizedBox(height: layoutConfig.spacing),
      },
      itemBuilder: (context, index) => LeadingTrailingAwareChildBuilder(
        index: index,
        itemCount: itemCount,
        builder: cellBuilder,
        leadingWidgets: leadingWidgets,
        trailingWidgets: trailingWidgets,
      ),
    );
  }
}
