import 'package:flutter/widgets.dart';

sealed class SelectionFeedbackConfig {
  final int feedbackDurationInMillis;

  const SelectionFeedbackConfig({
    required this.feedbackDurationInMillis,
  });
}

final class OpacityFeedbackConfig extends SelectionFeedbackConfig {
  final double opacity;

  const OpacityFeedbackConfig({
    this.opacity = 0.6,
    super.feedbackDurationInMillis = 100,
  }) : assert(
          opacity >= 0.0 && opacity <= 1.0,
          'Opacity must be between 0.0 and 1.0',
        );
}

final class OverlayFeedbackConfig extends SelectionFeedbackConfig {
  final Color overlayColor;

  const OverlayFeedbackConfig(
    this.overlayColor, {
    super.feedbackDurationInMillis = 100,
  });
}
