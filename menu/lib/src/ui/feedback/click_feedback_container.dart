import 'package:flutter/widgets.dart';
import 'package:menu/src/configs/selection_feedback_config.dart';
import 'package:menu/src/ui/feedback/opacity_feedback_container.dart';
import 'package:menu/src/ui/feedback/overlay_feedback_container.dart';

class ClickFeedbackContainer extends StatelessWidget {
  final Widget child;
  final void Function() onTap;
  final SelectionFeedbackConfig feedbackConfig;

  const ClickFeedbackContainer({
    super.key,
    required this.feedbackConfig,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final config = feedbackConfig;
    return switch (config) {
      OpacityFeedbackConfig() => OpacityFeedbackContainer(
          feedbackConfig: config,
          onTap: onTap,
          child: child,
        ),
      OverlayFeedbackConfig() => OverlayFeedbackContainer(
          feedbackConfig: config,
          onTap: onTap,
          child: child,
        )
    };
  }
}
