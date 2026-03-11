import 'package:flutter/widgets.dart';
import 'package:radio_group/src/configs/radio_group_layout_config.dart';
import 'package:radio_group/src/models/radio_item_ui_model.dart';
import 'package:radio_group/src/radio_groups/radio_group_base.dart';
import 'package:radio_group/src/widgets/leading_trailing_aware_child.dart';

class GridRadioGroup<T extends RadioItemUiModel>
    extends RadioGroupBase<T, GridLayoutConfig> {
  final List<Widget> _leadingWidgets;
  final List<Widget> _trailingWidgets;

  const GridRadioGroup({
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
    GridLayoutConfig layoutConfig,
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
        mainAxisSpacing: _calculateMainAxisSpacing(layoutConfig),
        crossAxisSpacing: _calculateCrossAxisSpacing(layoutConfig),
      ),
    );
  }

  double _calculateMainAxisSpacing(GridLayoutConfig layoutConfig) {
    final mainAxis = switch (layoutConfig.axis) {
      Axis.vertical => Axis.vertical,
      _ => Axis.horizontal
    };

    return _getSpacingForAxis(mainAxis, layoutConfig);
  }

  double _calculateCrossAxisSpacing(GridLayoutConfig layoutConfig) {
    final crossAxis = switch (layoutConfig.axis) {
      Axis.vertical => Axis.horizontal,
      _ => Axis.vertical
    };

    return _getSpacingForAxis(crossAxis, layoutConfig);
  }

  double _getSpacingForAxis(Axis axis, GridLayoutConfig layoutConfig) {
    return switch (axis) {
      Axis.vertical => layoutConfig.verticalSpacing,
      Axis.horizontal => layoutConfig.horizontalSpacing
    };
  }
}
