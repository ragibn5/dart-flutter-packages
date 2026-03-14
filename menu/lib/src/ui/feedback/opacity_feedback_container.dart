import 'package:flutter/widgets.dart';
import 'package:menu/src/configs/selection_feedback_config.dart';

/// Simple opacity-based feedback implementation
class OpacityFeedbackContainer extends StatefulWidget {
  final OpacityFeedbackConfig feedbackConfig;
  final HitTestBehavior hitTestBehavior;
  final void Function() onTap;
  final Widget child;

  const OpacityFeedbackContainer({
    super.key,
    required this.feedbackConfig,
    this.hitTestBehavior = HitTestBehavior.opaque,
    required this.onTap,
    required this.child,
  });

  @visibleForTesting
  const OpacityFeedbackContainer.test({
    super.key,
    required this.feedbackConfig,
    required this.onTap,
    required this.child,
  }) : hitTestBehavior = HitTestBehavior.opaque;

  @override
  State<OpacityFeedbackContainer> createState() =>
      _OpacityFeedbackContainerState();
}

class _OpacityFeedbackContainerState extends State<OpacityFeedbackContainer> {
  bool _isTouchActive = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.hitTestBehavior,
      onTapDown: (_) => setState(() => _isTouchActive = true),
      onTapUp: (_) {
        setState(() => _isTouchActive = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isTouchActive = false),
      child: AnimatedOpacity(
        opacity: _isTouchActive ? widget.feedbackConfig.opacity : 1.0,
        duration: Duration(
          milliseconds: widget.feedbackConfig.feedbackDurationInMillis,
        ),
        child: widget.child,
      ),
    );
  }
}
