import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows centered tab demo for all radio group modes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('List'), findsOneWidget);
    expect(find.text('Grid'), findsOneWidget);
    expect(find.text('Wrap'), findsOneWidget);
    expect(find.text('List layout'), findsOneWidget);
    expect(find.text('Selected: Starter'), findsOneWidget);

    await tester.tap(find.text('Grid'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Grid layout'), findsOneWidget);

    await tester.tap(find.text('Wrap'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Wrap layout'), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_checked), findsWidgets);
  });
}
