import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snack_pack/snack_pack.dart';

void main() {
  group('SnackBarType', () {
    test('has all four types', () {
      expect(SnackBarType.values.length, 4);
      expect(SnackBarType.values, contains(SnackBarType.success));
      expect(SnackBarType.values, contains(SnackBarType.failure));
      expect(SnackBarType.values, contains(SnackBarType.warning));
      expect(SnackBarType.values, contains(SnackBarType.info));
    });
  });

  group('showCustomSnackBar', () {
    testWidgets('displays snack bar with correct message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    showCustomSnackBar(
                      context,
                      'Test message',
                      SnackBarType.success,
                    );
                  },
                  child: const Text('Show Snack Bar'),
                );
              },
            ),
          ),
        ),
      );

      // Tap the button to show the snack bar
      await tester.tap(find.text('Show Snack Bar'));
      await tester.pumpAndSettle();

      // Verify the message is displayed
      expect(find.text('Test message'), findsOneWidget);
    });

    testWidgets('displays success snack bar with check icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    showCustomSnackBar(
                      context,
                      'Success',
                      SnackBarType.success,
                    );
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('displays failure snack bar with error icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    showCustomSnackBar(
                      context,
                      'Failure',
                      SnackBarType.failure,
                    );
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('displays warning snack bar with warning icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    showCustomSnackBar(
                      context,
                      'Warning',
                      SnackBarType.warning,
                    );
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('displays info snack bar with info icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    showCustomSnackBar(
                      context,
                      'Info',
                      SnackBarType.info,
                    );
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('only one snack bar visible at a time',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        showCustomSnackBar(
                          context,
                          'First message',
                          SnackBarType.success,
                        );
                      },
                      child: const Text('Show First'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showCustomSnackBar(
                          context,
                          'Second message',
                          SnackBarType.failure,
                        );
                      },
                      child: const Text('Show Second'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Show first snack bar
      await tester.tap(find.text('Show First'));
      await tester.pumpAndSettle();
      expect(find.text('First message'), findsOneWidget);

      // Show second snack bar
      await tester.tap(find.text('Show Second'));
      await tester.pumpAndSettle();

      // First message should be gone, only second should be visible
      expect(find.text('First message'), findsNothing);
      expect(find.text('Second message'), findsOneWidget);
    });

    testWidgets('snack bar auto-dismisses after duration',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    showCustomSnackBar(
                      context,
                      'Auto dismiss',
                      SnackBarType.info,
                      duration: const Duration(milliseconds: 500),
                    );
                  },
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Message should be visible
      expect(find.text('Auto dismiss'), findsOneWidget);

      // Wait for duration + animation time
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Message should be gone
      expect(find.text('Auto dismiss'), findsNothing);
    });
  });
}
