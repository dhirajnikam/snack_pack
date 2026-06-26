// Edge cases & safety tests for snack_pack.
//
// Author: margaret-hamilton (peer w3)
//
// Philosophy: the inputs and sequences that break software are rarely the
// happy path. They are the rapid re-entries, the dispose-mid-flight races,
// the degenerate inputs (empty / enormous), and the missing preconditions
// (no Overlay ancestor). Each of those is exercised here. Where the library
// fails, we pin the failure mode with an explicit expectation so that a
// future change to that behavior is caught loudly rather than silently.
//
// These tests deliberately drive the GLOBAL mutable state in snack_pack.dart
// (`_currentSnackBarEntry`). Because that state is process-global, the
// sequencing between tests matters: every test that shows a snack bar must
// also drive it to full teardown (pumpAndSettle) so it does not leak an
// OverlayEntry or a pending Timer into the next test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snack_pack/snack_pack.dart';

/// Pumps a host app that exposes a single button which, when tapped, invokes
/// [onPressed] with a live, Overlay-backed [BuildContext].
Future<void> _pumpHost(
  WidgetTester tester,
  void Function(BuildContext context) onPressed, {
  String label = 'Show',
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return ElevatedButton(
              onPressed: () => onPressed(context),
              child: Text(label),
            );
          },
        ),
      ),
    ),
  );
}

void main() {
  group('Edge case: rapid replacement', () {
    testWidgets(
      'showing many snack bars in one frame leaves exactly one visible',
      (WidgetTester tester) async {
        await _pumpHost(tester, (context) {
          // Fire five in immediate succession, synchronously, before any
          // frame is pumped. Each call must remove the prior overlay entry.
          // The contract: only one snack bar survives.
          for (var i = 0; i < 5; i++) {
            showCustomSnackBar(context, 'msg-$i', SnackBarType.info);
          }
        });

        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();

        // Only the final message survives; all earlier ones were removed.
        expect(find.text('msg-4'), findsOneWidget);
        for (var i = 0; i < 4; i++) {
          expect(find.text('msg-$i'), findsNothing);
        }
        // Exactly one snack bar Material is in the tree.
        expect(find.byType(Dismissible), findsOneWidget);

        // Let the survivor auto-dismiss so nothing leaks into the next test.
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'sequential taps replace the previous snack bar',
      (WidgetTester tester) async {
        // A single, stable host with two distinct buttons. Re-pumping a fresh
        // host would NOT remove an overlay entry inserted into the previous
        // tree's Overlay, so the only correct way to test replacement is to
        // keep one Overlay alive and fire successive shows into it.
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (BuildContext context) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => showCustomSnackBar(
                            context, 'seq-A', SnackBarType.success),
                        child: const Text('A'),
                      ),
                      ElevatedButton(
                        onPressed: () => showCustomSnackBar(
                            context, 'seq-B', SnackBarType.failure),
                        child: const Text('B'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('A'));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.text('B'));
        await tester.pumpAndSettle();

        // Only the last show survives; the prior overlay entry was removed.
        expect(find.byType(Dismissible), findsOneWidget);
        expect(find.text('seq-A'), findsNothing);
        expect(find.text('seq-B'), findsOneWidget);

        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
      },
    );
  });

  group('Edge case: replacement mid-animation', () {
    testWidgets(
      'replacing while the previous slide-in is still running keeps one visible',
      (WidgetTester tester) async {
        // Single Overlay kept alive; two buttons fire into it. The second
        // show happens while the first bar's 250ms slide-in is still running.
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (BuildContext context) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => showCustomSnackBar(
                            context, 'first', SnackBarType.warning),
                        child: const Text('first-btn'),
                      ),
                      ElevatedButton(
                        onPressed: () => showCustomSnackBar(
                            context, 'second', SnackBarType.failure),
                        child: const Text('second-btn'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('first-btn'));
        // Advance only PART of the 250ms slide-in; the first bar is mid-flight.
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('first'), findsOneWidget);

        // Replace it while its AnimationController is still forwarding.
        await tester.tap(find.text('second-btn'));
        await tester.pump(const Duration(milliseconds: 100));

        // The first must be gone (its overlay entry was removed outright,
        // not animated out), the second present. No two-bar overlap.
        expect(find.text('first'), findsNothing);
        expect(find.text('second'), findsOneWidget);
        expect(find.byType(Dismissible), findsOneWidget);

        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
      },
    );
  });

  group('Edge case: swipe-up dismiss via Dismissible', () {
    testWidgets(
      'swiping up triggers the reverse animation and removes the bar',
      (WidgetTester tester) async {
        await _pumpHost(tester, (context) {
          showCustomSnackBar(
            context,
            'swipe me',
            SnackBarType.info,
            // Long duration so the auto-dismiss timer cannot be what removes it.
            duration: const Duration(seconds: 30),
          );
        });

        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();
        expect(find.text('swipe me'), findsOneWidget);

        // Fling upward on the snack bar. The Dismissible is configured with
        // DismissDirection.up and confirmDismiss returns false after calling
        // the custom reverse-animation dismiss, so removal happens via our
        // controller, not Dismissible's own slide-out.
        await tester.fling(
          find.text('swipe me'),
          const Offset(0, -300),
          1000,
        );
        await tester.pumpAndSettle();

        // The bar is gone even though the 30s timer never fired.
        expect(find.text('swipe me'), findsNothing);
        expect(find.byType(Dismissible), findsNothing);
      },
    );
  });

  group('Edge case: dispose mid-animation (no pending-timer / ticker errors)',
      () {
    testWidgets(
      'tearing down the host while the slide-in is running does not throw',
      (WidgetTester tester) async {
        await _pumpHost(tester, (context) {
          showCustomSnackBar(context, 'disposing', SnackBarType.success);
        });

        await tester.tap(find.text('Show'));
        // Mid slide-in: controller is forwarding, auto-dismiss Timer pending.
        await tester.pump(const Duration(milliseconds: 80));
        expect(find.text('disposing'), findsOneWidget);

        // Replace the entire widget tree. This disposes the overlay's State,
        // which must cancel the Timer and dispose the AnimationController
        // WITHOUT leaving a pending timer or a ticker leak. If dispose()
        // mishandled either, flutter_test fails the test at teardown.
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 500));

        // Reaching here with no thrown exception is the assertion.
        expect(find.text('disposing'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'tearing down DURING the reverse (auto-dismiss) animation does not throw',
      (WidgetTester tester) async {
        await _pumpHost(tester, (context) {
          showCustomSnackBar(
            context,
            'reverse-then-dispose',
            SnackBarType.warning,
            duration: const Duration(milliseconds: 100),
          );
        });

        await tester.tap(find.text('Show'));
        await tester.pump(const Duration(milliseconds: 120)); // slide-in done
        // Let the auto-dismiss timer fire and the reverse animation begin...
        await tester.pump(const Duration(milliseconds: 120));
        // ...then yank the tree out from under the in-flight reverse. The
        // `_controller.reverse().then(...)` callback guards on `mounted`, so
        // onDismissed must NOT fire against a disposed State.
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 300));

        expect(tester.takeException(), isNull);
      },
    );
  });

  group('Edge case: degenerate messages', () {
    testWidgets(
      'a very long message renders without overflow exceptions',
      (WidgetTester tester) async {
        final longMessage = 'word ' * 400; // ~2000 chars
        await _pumpHost(tester, (context) {
          showCustomSnackBar(context, longMessage, SnackBarType.info);
        });

        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();

        // The Text is wrapped in Expanded, so it should wrap rather than
        // overflow. No render exception should have been thrown.
        expect(find.text(longMessage), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'an empty message still renders the bar structure (icon + text)',
      (WidgetTester tester) async {
        await _pumpHost(tester, (context) {
          showCustomSnackBar(context, '', SnackBarType.failure);
        });

        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();

        // Empty string is a valid Text; the icon and the Material wrapper
        // must still be present. Degenerate input must not collapse the UI.
        expect(find.text(''), findsOneWidget);
        expect(find.byIcon(Icons.error), findsOneWidget);
        expect(find.byType(Dismissible), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
      },
    );
  });

  group('Failure mode: missing Overlay precondition', () {
    testWidgets(
      'calling with a context that has no Overlay ancestor throws',
      (WidgetTester tester) async {
        // A bare Directionality with NO MaterialApp / Navigator / Overlay.
        // `Overlay.of(context)` is documented to assert/throw when no Overlay
        // ancestor exists. We pin that as the documented failure mode: the
        // library does NOT silently swallow a missing precondition.
        late BuildContext capturedContext;
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (BuildContext context) {
                capturedContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        // FlutterError is what Overlay.of throws when the ancestor is absent.
        expect(
          () => showCustomSnackBar(
            capturedContext,
            'no overlay here',
            SnackBarType.info,
          ),
          throwsA(isA<FlutterError>()),
        );
      },
    );
  });
}
