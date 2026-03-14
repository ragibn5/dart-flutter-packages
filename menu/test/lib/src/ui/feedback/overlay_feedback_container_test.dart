import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menu/src/configs/selection_feedback_config.dart';
import 'package:menu/src/ui/feedback/overlay_feedback_container.dart';

void main() {
  final visibleChild = Container(width: 100, height: 100, color: Colors.amber);

  Widget wrap(Widget child) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: child,
    );
  }

  testWidgets('Overlay is not visible initially', (tester) async {
    const config = OverlayFeedbackConfig(Color(0xFFFFFFFF));

    await tester.pumpWidget(
      wrap(
        OverlayFeedbackContainer.test(
          feedbackConfig: config,
          onTap: () {},
          child: visibleChild,
        ),
      ),
    );

    final visibility = tester.widget<Visibility>(find.byType(Visibility));
    expect(visibility.visible, false);
  });

  testWidgets('Overlay becomes visible on tap down', (tester) async {
    const config = OverlayFeedbackConfig(Color(0xFFFFFFFF));

    await tester.pumpWidget(
      wrap(
        OverlayFeedbackContainer.test(
          feedbackConfig: config,
          onTap: () {},
          child: visibleChild,
        ),
      ),
    );

    await tester.startGesture(tester.getCenter(find.byType(GestureDetector)));
    await tester.pump();

    final visibility = tester.widget<Visibility>(find.byType(Visibility));
    expect(visibility.visible, true);
  });

  testWidgets('Overlay hides on tap up', (tester) async {
    const config = OverlayFeedbackConfig(Color(0xFFFFFFFF));

    await tester.pumpWidget(
      wrap(
        OverlayFeedbackContainer.test(
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

    final visibility = tester.widget<Visibility>(find.byType(Visibility));
    expect(visibility.visible, false);
  });

  testWidgets('Calls onTap when tapped', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      wrap(
        OverlayFeedbackContainer.test(
          feedbackConfig: const OverlayFeedbackConfig(Color(0xFFFFFFFF)),
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
    const config = OverlayFeedbackConfig(
      Color(0xFFFFFFFF),
      feedbackDurationInMillis: 250,
    );

    await tester.pumpWidget(
      wrap(
        OverlayFeedbackContainer.test(
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
    expect(animatedOpacity.duration, const Duration(milliseconds: 250));
  });

  testWidgets('Overlay uses correct color from config', (tester) async {
    const overlayColor = Color(0xFFFF0000);
    const config = OverlayFeedbackConfig(overlayColor);

    await tester.pumpWidget(
      wrap(
        OverlayFeedbackContainer.test(
          feedbackConfig: config,
          onTap: () {},
          child: visibleChild,
        ),
      ),
    );

    await tester.startGesture(tester.getCenter(find.byType(GestureDetector)));
    await tester.pump();

    final coloredBox = tester.widget<ColoredBox>(
      find.descendant(
        of: find.byType(Visibility),
        matching: find.byType(ColoredBox),
      ),
    );
    expect(coloredBox.color, overlayColor);
  });

  testWidgets('Overlay hides when tap is cancelled', (tester) async {
    const config = OverlayFeedbackConfig(Color(0xFFFFFFFF));

    await tester.pumpWidget(
      wrap(
        OverlayFeedbackContainer.test(
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

    final visibility = tester.widget<Visibility>(find.byType(Visibility));
    expect(visibility.visible, false);
  });
}
