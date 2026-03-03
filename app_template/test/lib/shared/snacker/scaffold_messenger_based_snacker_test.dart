import 'package:app_template/shared/snacker/scaffold_messenger_based_snacker.dart';
import 'package:app_template/shared/snacker/snack_data.dart';
import 'package:app_template/shared/snacker/snack_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  late ScaffoldMessengerBasedSnacker snacker;

  setUp(() {
    scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
    snacker = ScaffoldMessengerBasedSnacker(scaffoldMessengerKey);
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

  group('ScaffoldMessengerBasedSnacker', () {
    test('throws StateError when key has no currentState', () {
      expect(
        () => snacker.showTextSnack(SnackData.info(message: 'test')),
        throwsA(isA<StateError>()),
      );
    });

    testWidgets('clears previous snack bar before showing new one', (
      tester,
    ) async {
      await pumpScaffold(tester);

      snacker.showTextSnack(SnackData.info(message: 'First'));
      await tester.pump();
      snacker.showTextSnack(SnackData.info(message: 'Second'));
      await tester.pump();

      expect(find.text('First'), findsNothing);
      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets(
      'renders message, duration, and text alignment from SnackData',
      (tester) async {
        await pumpScaffold(tester);

        snacker.showTextSnack(
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
    test('each factory sets the correct SnackType', () {
      expect(SnackData.info(message: '').snackType, SnackType.INFO);
      expect(SnackData.success(message: '').snackType, SnackType.SUCCESS);
      expect(SnackData.warning(message: '').snackType, SnackType.WARNING);
      expect(SnackData.error(message: '').snackType, SnackType.ERROR);
    });

    test('defaults to 2s duration and center alignment', () {
      final data = SnackData.info(message: 'test');
      expect(data.duration, const Duration(seconds: 2));
      expect(data.textAlignment, TextAlign.center);
    });
  });
}
