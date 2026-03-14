import 'package:flutter/widgets.dart';

sealed class SelectionFeedbackConfig {
  /// The duration of the feedback in milliseconds.
  final int feedbackDurationInMillis;

  const SelectionFeedbackConfig({
    required this.feedbackDurationInMillis,
  });
}

final class OpacityFeedbackConfig extends SelectionFeedbackConfig {
  /// The opacity of the feedback.
  ///
  /// Must be between 0.0 to 1.0.
  /// Any value outside this range will be clamped to the nearest bound.
  final double opacity;

  const OpacityFeedbackConfig({
    this.opacity = 0.6,
    super.feedbackDurationInMillis = 100,
  });
}

final class OverlayFeedbackConfig extends SelectionFeedbackConfig {
  /// The color of the feedback overlay.
  final Color overlayColor;

  const OverlayFeedbackConfig(
    this.overlayColor, {
    super.feedbackDurationInMillis = 100,
  });
}
