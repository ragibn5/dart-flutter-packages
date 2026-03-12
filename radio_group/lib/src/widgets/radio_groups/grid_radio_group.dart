import 'package:flutter/widgets.dart';
import 'package:radio_group/src/configs/radio_group_layout_config.dart';
import 'package:radio_group/src/models/radio_item_ui_model.dart';
import 'package:radio_group/src/widgets/builders/leading_trailing_aware_child_builder.dart';
import 'package:radio_group/src/widgets/radio_groups/radio_group_base.dart';

class GridRadioGroup<T extends RadioItemUiModel>
    extends RadioGroupBase<T, GridLayoutConfig> {
  final List<Widget> leadingWidgets;
  final List<Widget> trailingWidgets;

  const GridRadioGroup({
    super.key,
    required super.uiModels,
    required super.layoutConfig,
    super.initialSelectionIndex,
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
