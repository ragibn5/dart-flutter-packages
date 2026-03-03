import 'package:flutter/widgets.dart';
import 'package:radio_group/src/configs/radio_group_layout_config.dart';
import 'package:radio_group/src/models/radio_item_ui_model.dart';
import 'package:radio_group/src/radio_groups/radio_group_base.dart';
import 'package:radio_group/src/widgets/leading_trailing_aware_child.dart';

class ListRadioGroup<T extends RadioItemUiModel>
    extends RadioGroupBase<T, ListRadioGroupLayoutConfig> {
  final List<Widget> _leadingWidgets;
  final List<Widget> _trailingWidgets;

  const ListRadioGroup({
    super.key,
    required super.uiModels,
    required super.layoutConfig,
    required super.cellBuilder,
    required super.onSelectionChanged,
    super.initialSelectionIndex,
    List<Widget> leadingWidgets = const [],
    List<Widget> trailingWidgets = const [],
  })  : _leadingWidgets = leadingWidgets,
        _trailingWidgets = trailingWidgets;

  @override
  Widget buildContentWidget(
    int itemCount,
    ListRadioGroupLayoutConfig layoutConfig,
    Widget Function(int index) cellBuilder,
  ) {
    return ListView.separated(
      shrinkWrap: layoutConfig.shrinkWrap,
      padding: layoutConfig.padding,
      physics: layoutConfig.physics,
      scrollDirection: layoutConfig.axis,
      itemCount: itemCount + _leadingWidgets.length + _trailingWidgets.length,
      separatorBuilder: (context, index) => switch (layoutConfig.axis) {
        Axis.horizontal => SizedBox(width: layoutConfig.spacing),
        Axis.vertical => SizedBox(height: layoutConfig.spacing),
      },
      itemBuilder: (context, index) => LeadingTrailingAwareChildBuilder(
        index: index,
        itemCount: itemCount,
        builder: cellBuilder,
        leadingWidgets: _leadingWidgets,
        trailingWidgets: _trailingWidgets,
      ),
    );
  }
}
