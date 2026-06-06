// ignore_for_file: lines_longer_than_80_chars

import 'package:alerter/alerter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockContext extends Mock implements BuildContext {}

class _MockNavigatorKey extends Mock implements GlobalKey<NavigatorState> {}

void main() {
  late _MockContext mockContext;
  late _MockNavigatorKey mockNavigatorKey;

  late RouterNavigatorAlerter sut;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    mockContext = _MockContext();
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

  testWidgets(
    'AlertDialog returned from `buildAlertDialog` should have proper values',
    (tester) async {
      final alertData = AlertData.error(
        title: 'Title',
        message: 'This is a test error alert',
        actions: [
          CloseAction(title: 'Close', closingValue: false),
          PromptAction(title: 'Continue', onTap: () => true),
        ],
      );

      when(() => mockNavigatorKey.currentContext).thenReturn(mockContext);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: sut.buildAlertDialog(mockContext, alertData)),
        ),
      );

      expect(find.text(alertData.title), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.text(alertData.message), findsOneWidget);
      for (var i = 0; i < alertData.actions.length; i++) {
        expect(find.text(alertData.actions[i].title), findsOneWidget);
      }
    },
  );
}
