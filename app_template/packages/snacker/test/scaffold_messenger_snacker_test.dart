import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:snacker/snacker.dart';

class _MockScaffoldMessengerKey extends Mock
    implements GlobalKey<ScaffoldMessengerState> {}

void main() {
  late _MockScaffoldMessengerKey mockScaffoldMessengerKey;
  late GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  late ScaffoldMessengerSnacker sut;

  setUp(() {
    mockScaffoldMessengerKey = _MockScaffoldMessengerKey();
    scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
    sut = ScaffoldMessengerSnacker(scaffoldMessengerKey);
  });

  Future<void> pumpScaffold(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ScaffoldMessenger(
          key: scaffoldMessengerKey,
          child: const Scaffold(body: SizedBox()),
        ),
      ),
    );
  }

  group('ScaffoldMessengerSnacker', () {
    test('Throws StateError when key has no currentState', () {
      sut = ScaffoldMessengerSnacker(mockScaffoldMessengerKey);

      when(() => mockScaffoldMessengerKey.currentState).thenReturn(null);

      expect(
        () => sut.showTextSnack(SnackData.info(message: 'test')),
        throwsA(isA<StateError>()),
      );
    });

    testWidgets('Clears previous snack bar before showing new one', (
      tester,
    ) async {
      await pumpScaffold(tester);

      sut.showTextSnack(SnackData.info(message: 'First'));
      await tester.pump();
      sut.showTextSnack(SnackData.info(message: 'Second'));
      await tester.pump();

      expect(find.text('First'), findsNothing);
      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets(
      'Renders message, duration, and text alignment from SnackData',
      (tester) async {
        await pumpScaffold(tester);

        sut.showTextSnack(
          SnackData.error(
            message: 'Something went wrong',
            duration: const Duration(seconds: 5),
            textAlignment: TextAlign.start,
          ),
        );
        await tester.pump();

        final text = tester.widget<Text>(find.text('Something went wrong'));
        expect(text.textAlign, TextAlign.start);

        final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
        expect(snackBar.duration, const Duration(seconds: 5));
      },
    );
  });

  group('SnackData', () {
    test('Each factory sets the correct SnackType', () {
      expect(SnackData.info(message: '').snackType, SnackType.INFO);
      expect(SnackData.success(message: '').snackType, SnackType.SUCCESS);
      expect(SnackData.warning(message: '').snackType, SnackType.WARNING);
      expect(SnackData.error(message: '').snackType, SnackType.ERROR);
    });

    test('Defaults to 2s duration and center alignment', () {
      final data = SnackData.info(message: 'test');
      expect(data.duration, const Duration(seconds: 2));
      expect(data.textAlignment, TextAlign.center);
    });
  });
}
