import 'package:flutter/widgets.dart';
import 'package:menu/src/configs/selection_feedback_config.dart';

/// Overlay-based feedback implementation
class OverlayFeedbackContainer extends StatefulWidget {
  final Widget child;
  final void Function() onTap;
  final OverlayFeedbackConfig feedbackConfig;

  const OverlayFeedbackContainer({
    super.key,
    required this.child,
    required this.onTap,
    required this.feedbackConfig,
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
