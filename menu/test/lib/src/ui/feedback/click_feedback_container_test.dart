import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu/src/configs/selection_feedback_config.dart';
import 'package:menu/src/ui/feedback/click_feedback_container.dart';
import 'package:menu/src/ui/feedback/opacity_feedback_container.dart';
import 'package:menu/src/ui/feedback/overlay_feedback_container.dart';

void main() {
  Widget wrap(Widget sut) {
    return Directionality(textDirection: TextDirection.ltr, child: sut);
  }

  testWidgets(
      'Delegate to appropriate feedback container widget with proper values',
      (tester) async {
    const opacityFeedbackConfig = OpacityFeedbackConfig();
    const overlayFeedbackConfig = OverlayFeedbackConfig(Colors.white);
    const child = SizedBox.shrink();
    void onTap() {}
    final opacityBasedContainer = ClickFeedbackContainer(
      feedbackConfig: opacityFeedbackConfig,
      onTap: onTap,
      child: child,
    );
    final overlayBasedContainer = ClickFeedbackContainer(
      feedbackConfig: overlayFeedbackConfig,
      onTap: onTap,
      child: child,
    );

    await tester.pumpWidget(wrap(opacityBasedContainer));
    expect(
      tester.widget(find.byType(OpacityFeedbackContainer)),
      isA<OpacityFeedbackContainer>()
          .having(
              (w) => w.feedbackConfig, 'feedbackConfig', opacityFeedbackConfig)
          .having((w) => w.child, 'child', child)
          .having((w) => w.onTap, 'onTap', onTap),
    );

    await tester.pumpWidget(wrap(overlayBasedContainer));
    expect(
      tester.widget(find.byType(OverlayFeedbackContainer)),
      isA<OverlayFeedbackContainer>()
          .having(
              (w) => w.feedbackConfig, 'feedbackConfig', overlayFeedbackConfig)
          .having((w) => w.child, 'child', child)
          .having((w) => w.onTap, 'onTap', onTap),
    );
  });
}
