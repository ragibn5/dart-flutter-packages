import 'package:flutter/widgets.dart';

sealed class SelectionGroupLayoutConfig {
  const SelectionGroupLayoutConfig();
}

final class ListSelectionGroupLayoutConfig extends SelectionGroupLayoutConfig {
  final Axis axis;
  final double spacing;
  final EdgeInsets padding;
  final bool shrinkWrap;
  final ScrollPhysics physics;

  ListSelectionGroupLayoutConfig({
    this.axis = Axis.vertical,
    this.spacing = 0,
    this.padding = EdgeInsets.zero,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  factory ListSelectionGroupLayoutConfig.scrollable({
    Axis axis = Axis.vertical,
    double spacing = 0,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return ListSelectionGroupLayoutConfig(
      axis: axis,
      spacing: spacing,
      padding: padding,
      shrinkWrap: false,
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }

  factory ListSelectionGroupLayoutConfig.shrinkWrap({
    Axis axis = Axis.vertical,
    double spacing = 0,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return ListSelectionGroupLayoutConfig(
      axis: axis,
      spacing: spacing,
      padding: padding,
    );
  }
}

final class GridSelectionGroupLayoutConfig extends SelectionGroupLayoutConfig {
  final Axis axis;
  final int crossAxisItemCount;
  final double verticalSpacing;
  final double horizontalSpacing;
  final EdgeInsets padding;
  final bool shrinkWrap;
  final ScrollPhysics physics;

  const GridSelectionGroupLayoutConfig({
    this.axis = Axis.vertical,
    this.crossAxisItemCount = 3,
    this.verticalSpacing = 0,
    this.horizontalSpacing = 0,
    this.padding = EdgeInsets.zero,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  factory GridSelectionGroupLayoutConfig.scrollable({
    Axis axis = Axis.vertical,
    int crossAxisItemCount = 3,
    double verticalSpacing = 0,
    double horizontalSpacing = 0,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return GridSelectionGroupLayoutConfig(
      axis: axis,
      crossAxisItemCount: crossAxisItemCount,
      verticalSpacing: verticalSpacing,
      horizontalSpacing: horizontalSpacing,
      padding: padding,
      shrinkWrap: false,
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }

  factory GridSelectionGroupLayoutConfig.shrinkWrap({
    Axis axis = Axis.vertical,
    int crossAxisItemCount = 3,
    double verticalSpacing = 0,
    double horizontalSpacing = 0,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return GridSelectionGroupLayoutConfig(
      axis: axis,
      crossAxisItemCount: crossAxisItemCount,
      verticalSpacing: verticalSpacing,
      horizontalSpacing: horizontalSpacing,
      padding: padding,
    );
  }
}

final class WrapSelectionGroupLayoutConfig extends SelectionGroupLayoutConfig {
  final Axis axis;
  final double spacing;
  final double runSpacing;

  WrapSelectionGroupLayoutConfig({
    this.axis = Axis.horizontal,
    this.spacing = 0,
    this.runSpacing = 0,
  });
}
