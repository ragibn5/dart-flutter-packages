import 'package:flutter/widgets.dart';
import 'package:menu/src/configs/selection_feedback_config.dart';

/// Overlay-based feedback implementation
class OverlayFeedbackContainer extends StatefulWidget {
  final OverlayFeedbackConfig feedbackConfig;
  final void Function() onTap;
  final Widget child;

  const OverlayFeedbackContainer({
    super.key,
    required this.feedbackConfig,
    required this.onTap,
    required this.child,
  });

  @override
  State<OverlayFeedbackContainer> createState() =>
      _OverlayFeedbackContainerState();
}

class _OverlayFeedbackContainerState extends State<OverlayFeedbackContainer> {
  bool _isTouchActive = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isTouchActive = true),
      onTapUp: (_) {
        setState(() => _isTouchActive = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isTouchActive = false),
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: Visibility(
              visible: _isTouchActive,
              child: AnimatedOpacity(
                opacity: _isTouchActive ? 1.0 : 0.0,
                duration: Duration(
                  milliseconds: widget.feedbackConfig.feedbackDurationInMillis,
                ),
                child: ColoredBox(color: widget.feedbackConfig.overlayColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
