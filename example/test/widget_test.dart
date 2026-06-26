// Smoke tests for the snack_pack example app.
//
// These replace the default `flutter create` counter template (which tested a
// counter app this demo never was) with assertions against the real demo: that
// the home screen renders, that a type button shows its snack bar, and that the
// increment FAB updates the counter.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:snack_pack_example/main.dart';

void main() {
  testWidgets('demo home screen renders its controls', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Snack Pack Examples'), findsOneWidget);
    expect(find.text('Show Success'), findsOneWidget);
    expect(find.text('Show Failure'), findsOneWidget);
    expect(find.text('Show Warning'), findsOneWidget);
    expect(find.text('Show Info'), findsOneWidget);
  });

  testWidgets('tapping a type button shows its snack bar', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.ensureVisible(find.text('Show Success'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show Success'));
    await tester.pumpAndSettle();

    expect(
      find.text('Success! Operation completed successfully.'),
      findsOneWidget,
    );
  });

  testWidgets('increment FAB bumps the counter', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Counter: 0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Counter: 1'), findsOneWidget);
  });
}
