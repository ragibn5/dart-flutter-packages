import 'package:flutter/widgets.dart';
import 'package:radio_group/src/configs/radio_group_layout_config.dart';
import 'package:radio_group/src/models/radio_item_ui_model.dart';
import 'package:radio_group/src/widgets/builders/leading_trailing_aware_child_builder.dart';
import 'package:radio_group/src/widgets/radio_groups/radio_group_base.dart';

class WrapRadioGroup<T extends RadioItemUiModel>
    extends RadioGroupBase<T, WrapLayoutConfig> {
  final List<Widget> _leadingWidgets;
  final List<Widget> _trailingWidgets;

  const WrapRadioGroup({
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
