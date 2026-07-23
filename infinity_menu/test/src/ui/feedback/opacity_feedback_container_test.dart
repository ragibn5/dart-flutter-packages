import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinity_menu/src/configs/selection_feedback_config.dart';
import 'package:infinity_menu/src/ui/feedback/opacity_feedback_container.dart';

void main() {
  final visibleChild = Container(width: 100, height: 100, color: Colors.amber);

  Widget wrap(Widget child) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: child,
    );
  }

  testWidgets('Initial opacity is 1.0', (tester) async {
    const config = OpacityFeedbackConfig(opacity: 0.5);

    await tester.pumpWidget(
      wrap(
        OpacityFeedbackContainer.test(
          feedbackConfig: config,
          onTap: () {},
          child: visibleChild,
        ),
      ),
    );

    final animatedOpacity =
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
    expect(animatedOpacity.opacity, 1.0);
  });

  testWidgets('Opacity changes on tap down', (tester) async {
    const config = OpacityFeedbackConfig(opacity: 0.4);

    await tester.pumpWidget(
      wrap(
        OpacityFeedbackContainer.test(
          feedbackConfig: config,
          onTap: () {},
          child: visibleChild,
        ),
      ),
    );

    await tester.startGesture(tester.getCenter(find.byType(GestureDetector)));
    await tester.pump();

    final animatedOpacity =
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
    expect(animatedOpacity.opacity, 0.4);
  });

  testWidgets('Opacity resets to 1.0 on tap up', (tester) async {
    const config = OpacityFeedbackConfig(opacity: 0.3);

    await tester.pumpWidget(
      wrap(
        OpacityFeedbackContainer.test(
          feedbackConfig: config,
          onTap: () {},
          child: visibleChild,
        ),
      ),
    );

    final gesture = await tester
        .startGesture(tester.getCenter(find.byType(GestureDetector)));
    await tester.pump();

    await gesture.up();
    await tester.pump();

    final animatedOpacity =
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
    expect(animatedOpacity.opacity, 1.0);
  });

  testWidgets('Calls onTap when tapped', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      wrap(
        OpacityFeedbackContainer.test(
          feedbackConfig: const OpacityFeedbackConfig(),
          onTap: () => tapped = true,
          child: visibleChild,
        ),
      ),
    );

    final gesture = await tester
        .startGesture(tester.getCenter(find.byType(GestureDetector)));
    await gesture.up();
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('Animation duration uses config value', (tester) async {
    const config = OpacityFeedbackConfig(feedbackDurationInMillis: 250);

    await tester.pumpWidget(
      wrap(
        OpacityFeedbackContainer.test(
          feedbackConfig: config,
          onTap: () {},
          child: visibleChild,
        ),
      ),
    );

    final animatedOpacity =
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
    expect(animatedOpacity.duration, const Duration(milliseconds: 250));
  });

  testWidgets('Opacity resets when tap is cancelled', (tester) async {
    const config = OpacityFeedbackConfig(opacity: 0.5);

    await tester.pumpWidget(
      wrap(
        OpacityFeedbackContainer.test(
          feedbackConfig: config,
          onTap: () {},
          child: visibleChild,
        ),
      ),
    );

    final gesture = await tester
        .startGesture(tester.getCenter(find.byType(GestureDetector)));
    await tester.pump();

    await gesture.cancel();
    await tester.pump();

    final animatedOpacity =
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
    expect(animatedOpacity.opacity, 1.0);
  });
}
