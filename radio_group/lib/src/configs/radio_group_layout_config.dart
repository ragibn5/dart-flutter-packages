import 'package:flutter/widgets.dart';

sealed class RadioGroupLayoutConfig {
  const RadioGroupLayoutConfig();
}

final class ListRadioGroupLayoutConfig extends RadioGroupLayoutConfig {
  final Axis axis;
  final double spacing;
  final EdgeInsets padding;
  final bool shrinkWrap;
  final ScrollPhysics physics;

  ListRadioGroupLayoutConfig({
    this.axis = Axis.vertical,
    this.spacing = 0,
    this.padding = EdgeInsets.zero,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  factory ListRadioGroupLayoutConfig.scrollable({
    Axis axis = Axis.vertical,
    double spacing = 0,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return ListRadioGroupLayoutConfig(
      axis: axis,
      spacing: spacing,
      padding: padding,
      shrinkWrap: false,
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }

  factory ListRadioGroupLayoutConfig.shrinkWrap({
    Axis axis = Axis.vertical,
    double spacing = 0,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return ListRadioGroupLayoutConfig(
      axis: axis,
      spacing: spacing,
      padding: padding,
    );
  }
}

final class GridRadioGroupLayoutConfig extends RadioGroupLayoutConfig {
  final Axis axis;
  final int crossAxisItemCount;
  final double verticalSpacing;
  final double horizontalSpacing;
  final EdgeInsets padding;
  final bool shrinkWrap;
  final ScrollPhysics physics;

  const GridRadioGroupLayoutConfig({
    this.axis = Axis.vertical,
    this.crossAxisItemCount = 3,
    this.verticalSpacing = 0,
    this.horizontalSpacing = 0,
    this.padding = EdgeInsets.zero,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  factory GridRadioGroupLayoutConfig.scrollable({
    Axis axis = Axis.vertical,
    int crossAxisItemCount = 3,
    double verticalSpacing = 0,
    double horizontalSpacing = 0,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return GridRadioGroupLayoutConfig(
      axis: axis,
      crossAxisItemCount: crossAxisItemCount,
      verticalSpacing: verticalSpacing,
      horizontalSpacing: horizontalSpacing,
      padding: padding,
      shrinkWrap: false,
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }

  factory GridRadioGroupLayoutConfig.shrinkWrap({
    Axis axis = Axis.vertical,
    int crossAxisItemCount = 3,
    double verticalSpacing = 0,
    double horizontalSpacing = 0,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return GridRadioGroupLayoutConfig(
      axis: axis,
      crossAxisItemCount: crossAxisItemCount,
      verticalSpacing: verticalSpacing,
      horizontalSpacing: horizontalSpacing,
      padding: padding,
    );
  }
}

final class WrapRadioGroupLayoutConfig extends RadioGroupLayoutConfig {
  final Axis axis;
  final double spacing;
  final double runSpacing;

  WrapRadioGroupLayoutConfig({
    this.axis = Axis.horizontal,
    this.spacing = 0,
    this.runSpacing = 0,
  });
}
