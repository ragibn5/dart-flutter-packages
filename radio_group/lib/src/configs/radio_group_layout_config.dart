import 'package:flutter/widgets.dart';

sealed class RadioGroupLayoutConfig {
  const RadioGroupLayoutConfig();
}

final class ListLayoutConfig extends RadioGroupLayoutConfig {
  final Axis axis;
  final double spacing;
  final EdgeInsets padding;
  final bool shrinkWrap;
  final ScrollPhysics physics;

  ListLayoutConfig({
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

final class GridLayoutConfig extends RadioGroupLayoutConfig {
  final Axis axis;
  final int crossAxisItemCount;
  final double verticalSpacing;
  final double horizontalSpacing;
  final EdgeInsets padding;
  final bool shrinkWrap;
  final ScrollPhysics physics;

  const GridLayoutConfig({
    this.axis = Axis.vertical,
    this.crossAxisItemCount = 3,
    this.verticalSpacing = 0,
    this.horizontalSpacing = 0,
    this.padding = EdgeInsets.zero,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  factory GridLayoutConfig.scrollable({
    Axis axis = Axis.vertical,
    int crossAxisItemCount = 3,
    double verticalSpacing = 0,
    double horizontalSpacing = 0,
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
    );
  }

  factory GridLayoutConfig.shrinkWrap({
    Axis axis = Axis.vertical,
    int crossAxisItemCount = 3,
    double verticalSpacing = 0,
    double horizontalSpacing = 0,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return GridLayoutConfig(
      axis: axis,
      crossAxisItemCount: crossAxisItemCount,
      verticalSpacing: verticalSpacing,
      horizontalSpacing: horizontalSpacing,
      padding: padding,
    );
  }
}

final class WrapLayoutConfig extends RadioGroupLayoutConfig {
  final Axis axis;
  final double spacing;
  final double runSpacing;

  WrapLayoutConfig({
    this.axis = Axis.horizontal,
    this.spacing = 0,
    this.runSpacing = 0,
  });
}
