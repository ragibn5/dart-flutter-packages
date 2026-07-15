// ignore_for_file: lines_longer_than_80_chars

import 'package:alerty/alerty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A concrete [Alerty] that delegates context resolution to a settable
/// field so test code can inject any [BuildContext].
class _TestAlerty extends Alerty {
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

class _CustomTitleAlerty extends _TestAlerty {
  @override
  Widget? buildAlertTitle(AlertData data) {
    return const Text('Overridden Title');
  }
}

class _CustomIconAlerty extends _TestAlerty {
  @override
  Widget? buildAlertIcon(AlertData data) {
    return const Icon(Icons.star);
  }
}

class _CustomContentAlerty extends _TestAlerty {
  @override
  Widget? buildAlertContent(AlertData data) {
    return const Text('Overridden Content');
  }
}

class _CustomButtonAlerty extends _TestAlerty {
  @override
  Widget buildActionButton(String title, void Function() onTap) {
    return TextButton(onPressed: onTap, child: const Text('Custom Button'));
  }
}

class _FullOverrideAlerty extends _TestAlerty {
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
    testWidgets('Throws StateError when no context is available', (
      tester,
    ) async {
      final alerty = _TestAlerty();

      expect(
        () => alerty.showTextAlert(
          AlertData.error(title: 'Title', message: 'Message'),
          [],
        ),
        throwsA(isA<StateError>()),
      );
    });

    testWidgets('Displays default AlertDialog with all components', (
      tester,
    ) async {
      final alerty = _TestAlerty();
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
              alerty.provideContext(context);
              return ElevatedButton(
                onPressed: () => alerty.showTextAlert(data, actions),
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

    testWidgets('Tapping CloseAction dismisses the dialog', (tester) async {
      final alerty = _TestAlerty();
      final data = AlertData.error(title: 'Title', message: 'Message');
      final actions = [CloseAction<Never>(title: 'Dismiss')];

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              alerty.provideContext(context);
              return ElevatedButton(
                onPressed: () => alerty.showTextAlert(data, actions),
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
      final alerty = _TestAlerty();
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
              alerty.provideContext(context);
              return ElevatedButton(
                onPressed: () => alerty.showTextAlert(data, actions),
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

  group('Alert type icons', () {
    testWidgets('INFO shows info icon', (tester) async {
      final alerty = _TestAlerty();
      final data = AlertData.info(title: 'Info', message: 'Message');

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              alerty.provideContext(context);
              return ElevatedButton(
                onPressed: () => alerty.showTextAlert(data, []),
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
      final alerty = _TestAlerty();
      final data = AlertData.success(title: 'Success', message: 'Message');

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              alerty.provideContext(context);
              return ElevatedButton(
                onPressed: () => alerty.showTextAlert(data, []),
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
      final alerty = _TestAlerty();
      final data = AlertData.warning(title: 'Warning', message: 'Message');

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              alerty.provideContext(context);
              return ElevatedButton(
                onPressed: () => alerty.showTextAlert(data, []),
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
      final alerty = _TestAlerty();
      final data = AlertData.error(title: 'Error', message: 'Message');

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              alerty.provideContext(context);
              return ElevatedButton(
                onPressed: () => alerty.showTextAlert(data, []),
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
      final alerty = _TestAlerty();
      final data = AlertData.prompt(title: 'Prompt', message: 'Message');

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              alerty.provideContext(context);
              return ElevatedButton(
                onPressed: () => alerty.showTextAlert(data, []),
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

  group('Component overrides', () {
    testWidgets('buildAlertTitle override replaces title widget', (
      tester,
    ) async {
      final alerty = _CustomTitleAlerty();
      final data = AlertData.info(title: 'Original Title', message: 'Message');

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              alerty.provideContext(context);
              return ElevatedButton(
                onPressed: () => alerty.showTextAlert(data, []),
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
      final alerty = _CustomIconAlerty();
      final data = AlertData.info(title: 'Title', message: 'Message');

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              alerty.provideContext(context);
              return ElevatedButton(
                onPressed: () => alerty.showTextAlert(data, []),
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
      final alerty = _CustomContentAlerty();
      final data = AlertData.info(title: 'Title', message: 'Original Message');

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              alerty.provideContext(context);
              return ElevatedButton(
                onPressed: () => alerty.showTextAlert(data, []),
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
      final alerty = _CustomButtonAlerty();
      final data = AlertData.info(title: 'Title', message: 'Message');
      final actions = [CloseAction<Never>(title: 'Close')];

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              alerty.provideContext(context);
              return ElevatedButton(
                onPressed: () => alerty.showTextAlert(data, actions),
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

  group('Full dialog override', () {
    testWidgets('buildAlertDialog override replaces entire dialog', (
      tester,
    ) async {
      final alerty = _FullOverrideAlerty();
      final data = AlertData.error(
        title: 'Original Title',
        message: 'Original Message',
      );
      final actions = [CloseAction<Never>(title: 'Close')];

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              alerty.provideContext(context);
              return ElevatedButton(
                onPressed: () => alerty.showTextAlert(data, actions),
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
