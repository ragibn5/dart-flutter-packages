import 'package:flutter/widgets.dart';
import 'package:menu/src/configs/selection_feedback_config.dart';
import 'package:menu/src/ui/feedback/opacity_feedback_container.dart';
import 'package:menu/src/ui/feedback/overlay_feedback_container.dart';

class ClickFeedbackContainer extends StatelessWidget {
  final Widget _child;
  final void Function() _onTap;
  final SelectionFeedbackConfig _feedbackConfig;

  const ClickFeedbackContainer({
    super.key,
    required Widget child,
    required void Function() onTap,
    required SelectionFeedbackConfig feedbackType,
  })  : _child = child,
        _onTap = onTap,
        _feedbackConfig = feedbackType;

  @override
  Widget build(BuildContext context) {
    final config = _feedbackConfig;
    switch (config) {
      case OpacityFeedbackConfig():
        return OpacityFeedbackContainer(
          onTap: _onTap,
          feedbackConfig: config,
          child: _child,
        );
      case OverlayFeedbackConfig():
        return OverlayFeedbackContainer(
          onTap: _onTap,
          feedbackConfig: config,
          child: _child,
        );
    }
  }
}
