import 'package:flutter/widgets.dart';
import 'package:menu/src/configs/selection_feedback_config.dart';

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
        return _OpacityFeedbackContainer(
          onTap: _onTap,
          feedbackConfig: config,
          child: _child,
        );
      case OverlayFeedbackConfig():
        return _OverlayFeedbackContainer(
          onTap: _onTap,
          feedbackConfig: config,
          child: _child,
        );
    }
  }
}

/// Simple opacity-based feedback implementation
class _OpacityFeedbackContainer extends StatefulWidget {
  final Widget child;
  final void Function() onTap;
  final OpacityFeedbackConfig feedbackConfig;

  const _OpacityFeedbackContainer({
    super.key,
    required this.child,
    required this.onTap,
    required this.feedbackConfig,
  });

  @override
  State<_OpacityFeedbackContainer> createState() =>
      _OpacityFeedbackContainerState();
}

class _OpacityFeedbackContainerState extends State<_OpacityFeedbackContainer> {
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

/// Overlay-based feedback implementation
class _OverlayFeedbackContainer extends StatefulWidget {
  final Widget child;
  final void Function() onTap;
  final OverlayFeedbackConfig feedbackConfig;

  const _OverlayFeedbackContainer({
    super.key,
    required this.child,
    required this.onTap,
    required this.feedbackConfig,
  });

  @override
  State<_OverlayFeedbackContainer> createState() =>
      _OverlayFeedbackContainerState();
}

class _OverlayFeedbackContainerState extends State<_OverlayFeedbackContainer> {
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
