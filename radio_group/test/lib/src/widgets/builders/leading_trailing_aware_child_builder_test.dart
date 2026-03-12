import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_group/src/widgets/builders/leading_trailing_aware_child_builder.dart';

void main() {
  Widget wrap(Widget child) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: child,
    );
  }

  testWidgets('Returns correct leading widget when index within leading range',
      (tester) async {
    const leadingA = Text('leading-A');
    const leadingB = Text('leading-B');

    await tester.pumpWidget(
      wrap(
        LeadingTrailingAwareChildBuilder(
          index: 1,
          itemCount: 2,
          builder: (_) => const Text('content'),
          leadingWidgets: const [leadingA, leadingB],
          trailingWidgets: const [],
        ),
      ),
    );

    expect(find.text('leading-B'), findsOneWidget);
  });

  testWidgets('Returns trailing widget when index falls in trailing range',
      (tester) async {
    const trailingA = Text('trailing-A');

    await tester.pumpWidget(
      wrap(
        LeadingTrailingAwareChildBuilder(
          index: 3,
          itemCount: 2,
          builder: (_) => const Text('content'),
          leadingWidgets: const [Text('leading')],
          trailingWidgets: const [trailingA],
        ),
      ),
    );

    expect(find.text('trailing-A'), findsOneWidget);
  });

  testWidgets('Builder is used when index is in content region',
      (tester) async {
    await tester.pumpWidget(
      wrap(
        LeadingTrailingAwareChildBuilder(
          index: 1,
          itemCount: 3,
          builder: (i) => Text('content-$i'),
          leadingWidgets: const [Text('leading')],
          trailingWidgets: const [Text('trailing')],
        ),
      ),
    );

    expect(find.text('content-0'), findsOneWidget);
  });

  testWidgets('Works when leading and trailing lists are empty',
      (tester) async {
    await tester.pumpWidget(
      wrap(
        LeadingTrailingAwareChildBuilder(
          index: 0,
          itemCount: 2,
          builder: (i) => Text('content-$i'),
          leadingWidgets: const [],
          trailingWidgets: const [],
        ),
      ),
    );

    expect(find.text('content-0'), findsOneWidget);
  });
}
