import 'package:flutter/widgets.dart';

sealed class SelectionGroupLayoutConfig {
  const SelectionGroupLayoutConfig();
}

final class ListLayoutConfig extends SelectionGroupLayoutConfig {
  final Axis axis;
  final double spacing;
  final EdgeInsets padding;
  final bool shrinkWrap;
  final ScrollPhysics physics;

  const ListLayoutConfig({
    this.axis = Axis.vertical,
    this.spacing = 0,
    this.padding = EdgeInsets.zero,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  factory ListLayoutConfig.scrollable({
    Axis axis = Axis.vertical,
    double spacing = 0,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return ListLayoutConfig(
      axis: axis,
      spacing: spacing,
      padding: padding,
      shrinkWrap: false,
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }

  factory ListLayoutConfig.shrinkWrap({
    Axis axis = Axis.vertical,
    double spacing = 0,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return ListLayoutConfig(
      axis: axis,
      spacing: spacing,
      padding: padding,
    );
  }
}

final class GridLayoutConfig extends SelectionGroupLayoutConfig {
  final Axis axis;
  final int crossAxisItemCount;
  final double verticalSpacing;
  final double horizontalSpacing;
  final double childAspectRatio;
  final double? mainAxisExtent;
  final EdgeInsets padding;
  final bool shrinkWrap;
  final ScrollPhysics physics;

  const GridLayoutConfig({
    this.axis = Axis.vertical,
    this.crossAxisItemCount = 3,
    this.verticalSpacing = 0,
    this.horizontalSpacing = 0,
    this.childAspectRatio = 1.0,
    this.mainAxisExtent,
    this.padding = EdgeInsets.zero,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  factory GridLayoutConfig.scrollable({
    Axis axis = Axis.vertical,
    int crossAxisItemCount = 3,
    double verticalSpacing = 0,
    double horizontalSpacing = 0,
    double childAspectRatio = 1.0,
    double? mainAxisExtent,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return GridLayoutConfig(
      axis: axis,
      crossAxisItemCount: crossAxisItemCount,
      verticalSpacing: verticalSpacing,
      horizontalSpacing: horizontalSpacing,
      padding: padding,
      shrinkWrap: false,
      physics: const AlwaysScrollableScrollPhysics(),
      childAspectRatio: childAspectRatio,
      mainAxisExtent: mainAxisExtent,
    );
  }

  factory GridLayoutConfig.shrinkWrap({
    Axis axis = Axis.vertical,
    int crossAxisItemCount = 3,
    double verticalSpacing = 0,
    double horizontalSpacing = 0,
    EdgeInsets padding = EdgeInsets.zero,
    double childAspectRatio = 1.0,
    double? mainAxisExtent,
  }) {
    return GridLayoutConfig(
      axis: axis,
      crossAxisItemCount: crossAxisItemCount,
      verticalSpacing: verticalSpacing,
      horizontalSpacing: horizontalSpacing,
      padding: padding,
      childAspectRatio: childAspectRatio,
      mainAxisExtent: mainAxisExtent,
    );
  }
}

final class WrapLayoutConfig extends SelectionGroupLayoutConfig {
  final Axis axis;
  final double spacing;
  final double runSpacing;

  const WrapLayoutConfig({
    this.axis = Axis.horizontal,
    this.spacing = 0,
    this.runSpacing = 0,
  });
}
