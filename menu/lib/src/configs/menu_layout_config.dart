import 'package:flutter/widgets.dart';
import 'package:menu/src/configs/selection_feedback_config.dart';

class MenuLayoutConfig {
  final bool shrinkWrap;
  final EdgeInsets padding;
  final ScrollPhysics scrollPhysics;
  final SelectionFeedbackConfig selectionFeedbackConfig;

  const MenuLayoutConfig({
    this.shrinkWrap = true,
    this.padding = EdgeInsets.zero,
    this.scrollPhysics = const NeverScrollableScrollPhysics(),
    this.selectionFeedbackConfig = const OpacityFeedbackConfig(),
  });

  MenuLayoutConfig copyWith({
    bool? shrinkWrap,
    EdgeInsets? padding,
    ScrollPhysics? scrollPhysics,
  }) {
    return MenuLayoutConfig(
      shrinkWrap: shrinkWrap ?? this.shrinkWrap,
      padding: padding ?? this.padding,
      scrollPhysics: scrollPhysics ?? this.scrollPhysics,
    );
  }
}
