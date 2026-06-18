// ignore_for_file: lines_longer_than_80_chars

import 'package:alerter/alerter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A concrete [Alerter] that delegates context resolution to a settable
/// field so test code can inject any [BuildContext].
class _TestAlerter extends Alerter {
  BuildContext? _context;

  // ignore: use_setters_to_change_properties
  void provideContext(BuildContext context) => _context = context;

  @override
  BuildContext getCurrentContext() {
    final ctx = _context;
    if (ctx == null) throw StateError('No context set');
    return ctx;
  }
}

class _CustomTitleAlerter extends _TestAlerter {
  @override
  Widget? buildAlertTitle(AlertData data) {
    return const Text('Overridden Title');
  }
}

class _CustomIconAlerter extends _TestAlerter {
  @override
  Widget? buildAlertIcon(AlertData data) {
    return const Icon(Icons.star);
  }
}

class _CustomContentAlerter extends _TestAlerter {
  @override
  Widget? buildAlertContent(AlertData data) {
    return const Text('Overridden Content');
  }
}

class _CustomButtonAlerter extends _TestAlerter {
  @override
  Widget buildActionButton(String title, void Function() onTap) {
    return TextButton(onPressed: onTap, child: const Text('Custom Button'));
  }
}

class _FullOverrideAlerter extends _TestAlerter {
  @override
  Widget buildAlertDialog(AlertData alertData, List<Widget> actionButtons) {
    return AlertDialog(
      title: const Text('Full Override'),
      content: Text(alertData.message),
      actions: actionButtons,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('showTextAlert', () {
    testWidgets('throws StateError when no context is available', (
      tester,
    ) async {
      final alerter = _TestAlerter();

      expect(
        () => alerter.showTextAlert(
          AlertData.error(title: 'Title', message: 'Message'),
          [],
        ),
        throwsA(isA<StateError>()),
      );
    });

    testWidgets('displays default AlertDialog with all components', (
      tester,
    ) async {
      final alerter = _TestAlerter();
      final data = AlertData.error(
        title: 'Test Title',
        message: 'Test Message',
      );
      final actions = <AlertAction<Object?>>[
        CloseAction<Object?>(title: 'Close'),
        PromptAction<Object?>(title: 'Continue', onTap: () => true),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              alerter.provideContext(context);
              return ElevatedButton(
                onPressed: () => alerter.showTextAlert(data, actions),
                child: const Text('Show'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.text('Test Message'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('tapping CloseAction dismisses the dialog', (tester) async {
      final alerter = _TestAlerter();
      final data = AlertData.error(title: 'Title', message: 'Message');
      final actions = [CloseAction<Never>(title: 'Dismiss')];

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              alerter.provideContext(context);
              return ElevatedButton(
                onPressed: () => alerter.showTextAlert(data, actions),
                child: const Text('Show'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('PromptAction fires onTap callback', (tester) async {
      final alerter = _TestAlerter();
      var tapped = false;
      final data = AlertData.prompt(title: 'Prompt', message: 'Continue?');
      final actions = [
        PromptAction<Object?>(
          title: 'Yes',
          onTap: () {
            tapped = true;
            return null;
          },
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              alerter.provideContext(context);
              return ElevatedButton(
                onPressed: () => alerter.showTextAlert(data, actions),
                child: const Text('Show'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });

  group('alert type icons', () {
    testWidgets('INFO shows info icon', (tester) async {
      final alerter = _TestAlerter();
      final data = AlertData.info(title: 'Info', message: 'Message');

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              alerter.provideContext(context);
              return ElevatedButton(
                onPressed: () => alerter.showTextAlert(data, []),
                child: const Text('Show'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('SUCCESS shows check_circle icon', (tester) async {
      final alerter = _TestAlerter();
      final data = AlertData.success(title: 'Success', message: 'Message');

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              alerter.provideContext(context);
              return ElevatedButton(
                onPressed: () => alerter.showTextAlert(data, []),
                child: const Text('Show'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('WARNING shows warning icon', (tester) async {
      final alerter = _TestAlerter();
      final data = AlertData.warning(title: 'Warning', message: 'Message');

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              alerter.provideContext(context);
              return ElevatedButton(
                onPressed: () => alerter.showTextAlert(data, []),
                child: const Text('Show'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('ERROR shows error icon', (tester) async {
      final alerter = _TestAlerter();
      final data = AlertData.error(title: 'Error', message: 'Message');

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              alerter.provideContext(context);
              return ElevatedButton(
                onPressed: () => alerter.showTextAlert(data, []),
                child: const Text('Show'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('PROMPT shows question_mark_rounded icon', (tester) async {
      final alerter = _TestAlerter();
      final data = AlertData.prompt(title: 'Prompt', message: 'Message');

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              alerter.provideContext(context);
              return ElevatedButton(
                onPressed: () => alerter.showTextAlert(data, []),
                child: const Text('Show'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.question_mark_rounded), findsOneWidget);
    });
  });

  group('component overrides', () {
    testWidgets('buildAlertTitle override replaces title widget', (
      tester,
    ) async {
      final alerter = _CustomTitleAlerter();
      final data = AlertData.info(title: 'Original Title', message: 'Message');

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              alerter.provideContext(context);
              return ElevatedButton(
                onPressed: () => alerter.showTextAlert(data, []),
                child: const Text('Show'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('Overridden Title'), findsOneWidget);
      expect(find.text('Original Title'), findsNothing);
    });

    testWidgets('buildAlertIcon override replaces icon widget', (tester) async {
      final alerter = _CustomIconAlerter();
      final data = AlertData.info(title: 'Title', message: 'Message');

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              alerter.provideContext(context);
              return ElevatedButton(
                onPressed: () => alerter.showTextAlert(data, []),
                child: const Text('Show'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.info), findsNothing);
    });

    testWidgets('buildAlertContent override replaces content widget', (
      tester,
    ) async {
      final alerter = _CustomContentAlerter();
      final data = AlertData.info(title: 'Title', message: 'Original Message');

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              alerter.provideContext(context);
              return ElevatedButton(
                onPressed: () => alerter.showTextAlert(data, []),
                child: const Text('Show'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('Overridden Content'), findsOneWidget);
      expect(find.text('Original Message'), findsNothing);
    });

    testWidgets('buildActionButton override replaces button widget', (
      tester,
    ) async {
      final alerter = _CustomButtonAlerter();
      final data = AlertData.info(title: 'Title', message: 'Message');
      final actions = [CloseAction<Never>(title: 'Close')];

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              alerter.provideContext(context);
              return ElevatedButton(
                onPressed: () => alerter.showTextAlert(data, actions),
                child: const Text('Show'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('Custom Button'), findsOneWidget);
      expect(find.text('Close'), findsNothing);
    });
  });

  group('full dialog override', () {
    testWidgets('buildAlertDialog override replaces entire dialog', (
      tester,
    ) async {
      final alerter = _FullOverrideAlerter();
      final data = AlertData.error(
        title: 'Original Title',
        message: 'Original Message',
      );
      final actions = [CloseAction<Never>(title: 'Close')];

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              alerter.provideContext(context);
              return ElevatedButton(
                onPressed: () => alerter.showTextAlert(data, actions),
                child: const Text('Show'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.text('Full Override'), findsOneWidget);
      expect(find.text('Original Message'), findsOneWidget);
      expect(find.text('Original Title'), findsNothing);
    });
  });
}
