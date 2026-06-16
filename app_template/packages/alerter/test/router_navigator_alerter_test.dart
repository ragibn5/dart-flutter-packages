// ignore_for_file: lines_longer_than_80_chars

import 'package:alerter/alerter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockNavigatorKey extends Mock implements GlobalKey<NavigatorState> {}

void main() {
  late _MockNavigatorKey mockNavigatorKey;

  late RouterNavigatorAlerter sut;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    mockNavigatorKey = _MockNavigatorKey();

    sut = RouterNavigatorAlerter(mockNavigatorKey);
  });

  test(
    '`showTextAlert` should throw StateError if no navigator key is provided',
    () {
      final alertData = AlertData<dynamic>.error(
        title: 'Title',
        message: 'This is a test error alert',
      );

      when(() => mockNavigatorKey.currentContext).thenReturn(null);

      expect(() => sut.showTextAlert(alertData), throwsA(isA<StateError>()));
    },
  );

  testWidgets('showTextAlert should display AlertDialog with proper values', (
    tester,
  ) async {
    final alertData = AlertData.error(
      title: 'Title',
      message: 'This is a test error alert',
      actions: [
        CloseAction(title: 'Close', closingValue: false),
        PromptAction(title: 'Continue', onTap: () => true),
      ],
    );

    final navigatorKey = GlobalKey<NavigatorState>();
    final alerter = RouterNavigatorAlerter(navigatorKey);

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => alerter.showTextAlert(alertData),
            child: const Text('Show Alert'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Alert'));
    await tester.pumpAndSettle();

    expect(find.text(alertData.title), findsOneWidget);
    expect(find.byIcon(Icons.error), findsOneWidget);
    expect(find.text(alertData.message), findsOneWidget);
    for (var i = 0; i < alertData.actions.length; i++) {
      expect(find.text(alertData.actions[i].title), findsOneWidget);
    }
  });
}
