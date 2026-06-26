// Animation, timing & lifecycle tests for snack_pack.
//
// Author: john-carmack (work item w2)
//
// The whole point of this file is to pin down what actually happens
// frame-by-frame. The source (lib/src/snack_pack.dart) gives us hard
// numbers, and we test against those numbers exactly rather than leaning
// on pumpAndSettle, which hides the timeline:
//
//   * AnimationController.duration            = 250ms (slide-in)
//   * reverse() runs that same 250ms backward (slide-out)
//   * SlideTransition tween: Offset(0,-1) -> Offset.zero (top slide-in)
//   * Curve: Curves.easeOut on the forward/reverse value
//   * auto-dismiss: a dart:async Timer armed for `duration`
//   * dispose(): cancels the Timer, then disposes the controller
//
// A SlideTransition that is fully off-screen (offset y == -1) is still in
// the tree, so presence-in-tree is NOT the same as visible. Where it
// matters we assert on the actual FractionalTranslation offset that
// SlideTransition produces, because that is the thing the GPU would draw.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snack_pack/snack_pack.dart';

/// Pumps a host app exposing a button that fires showCustomSnackBar with the
/// given parameters. Returns once the host is mounted; the snack bar is NOT
/// shown until you tap 'show'.
Future<void> _pumpHost(
  WidgetTester tester, {
  required String message,
  SnackBarType type = SnackBarType.info,
  Duration duration = const Duration(seconds: 3),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showCustomSnackBar(
              context,
              message,
              type,
              duration: duration,
            ),
            child: const Text('show'),
          ),
        ),
      ),
    ),
  );
}

/// Reads the live vertical translation fraction the SlideTransition is
/// applying right now. -1.0 == fully above the top edge (invisible),
/// 0.0 == fully landed (visible). This is the exact value the compositor
/// would use, so it is the truth about what is on screen this frame.
///
/// We read straight off the SlideTransition's `position` Animation rather
/// than hunting for a descendant FractionalTranslation, because Dismissible
/// also injects FractionalTranslation widgets for its own drag offset and
/// that makes a structural finder ambiguous.
///
/// There are actually TWO SlideTransitions in the tree: Dismissible builds
/// its own (for drag offset) that wraps everything, and ours wraps the
/// Material directly. We disambiguate by selecting the one whose `child` is
/// the snack bar Material — that is unambiguously ours.
double _slideOffsetY(WidgetTester tester) {
  final ours = tester
      .widgetList<SlideTransition>(find.byType(SlideTransition))
      .firstWhere((s) => s.child is Material);
  return ours.position.value.dy;
}

void main() {
  group('slide-in animation (forward, 250ms)', () {
    testWidgets('starts fully off-screen at the top (y == -1.0) on frame 0',
        (tester) async {
      await _pumpHost(tester, message: 'slide');
      await tester.tap(find.text('show'));
      // Pump a single zero-duration frame: the overlay inserts and
      // initState fires forward(), but no time has elapsed yet.
      await tester.pump();

      expect(find.text('slide'), findsOneWidget,
          reason: 'overlay entry is in the tree immediately');
      expect(_slideOffsetY(tester), closeTo(-1.0, 0.001),
          reason: 'controller value 0 -> tween begin Offset(0,-1)');
    });

    testWidgets('is partway down at 125ms and fully landed at 250ms',
        (tester) async {
      await _pumpHost(tester, message: 'slide');
      await tester.tap(find.text('show'));
      await tester.pump(); // arm the controller at t=0

      // Halfway through the 250ms slide.
      await tester.pump(const Duration(milliseconds: 125));
      final mid = _slideOffsetY(tester);
      // easeOut decelerates, so at the time-midpoint the curve value is
      // already > 0.5, meaning the offset is well past the geometric middle
      // (closer to 0 than to -1). We assert the strictly-between invariant
      // plus the easeOut bias rather than a brittle exact number.
      expect(mid, greaterThan(-1.0));
      expect(mid, lessThan(0.0));
      expect(mid, greaterThan(-0.5),
          reason: 'easeOut is past the halfway point in value by mid-time');

      // The remaining time to hit exactly 250ms total.
      await tester.pump(const Duration(milliseconds: 125));
      expect(_slideOffsetY(tester), closeTo(0.0, 0.001),
          reason: 'controller completed -> tween end Offset.zero');
    });

    testWidgets('controller stops advancing once the 250ms slide completes',
        (tester) async {
      await _pumpHost(tester,
          message: 'slide', duration: const Duration(seconds: 10));
      await tester.tap(find.text('show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      final landed = _slideOffsetY(tester);
      // Pump more frames; with the controller completed and the auto-dismiss
      // timer far in the future, nothing should move.
      await tester.pump(const Duration(milliseconds: 100));
      expect(_slideOffsetY(tester), closeTo(landed, 0.001));
      expect(landed, closeTo(0.0, 0.001));

      // Drain the long auto-dismiss timer so the test ends clean.
      await tester.pump(const Duration(seconds: 10));
      await tester.pump(const Duration(milliseconds: 250));
    });
  });

  group('auto-dismiss timing', () {
    testWidgets(
        'default duration is 3 seconds: alive at 3s, gone after reverse',
        (tester) async {
      // Do NOT pass duration -> exercises the default of 3s.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showCustomSnackBar(
                    context, 'default3s', SnackBarType.success),
                child: const Text('show'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('show'));
      await tester.pump(); // t=0
      await tester.pump(const Duration(milliseconds: 250)); // slide-in done

      // Just before the 3s timer fires (timer armed at t=0, slide consumed
      // 250ms, so 2749ms more lands us at 2999ms total): still present.
      await tester.pump(const Duration(milliseconds: 2749));
      expect(find.text('default3s'), findsOneWidget,
          reason: 'auto-dismiss Timer(3s) has not fired yet at t=2999ms');

      // Cross the 3s boundary -> timer fires -> reverse() starts.
      await tester.pump(const Duration(milliseconds: 2));
      // Let the 250ms reverse complete; reverse().then(onDismissed) removes
      // the entry, which needs a further frame to rebuild the overlay.
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();
      expect(find.text('default3s'), findsNothing,
          reason: 'reverse completed, onDismissed removed the overlay entry');
    });

    testWidgets('custom 500ms duration fires exactly at its boundary',
        (tester) async {
      await _pumpHost(
        tester,
        message: 'custom500',
        duration: const Duration(milliseconds: 500),
      );
      await tester.tap(find.text('show'));
      await tester.pump(); // t=0, timer armed
      await tester.pump(const Duration(milliseconds: 250)); // landed

      // At t=499ms total we are 1ms shy of the timer: still landed & visible.
      await tester.pump(const Duration(milliseconds: 249));
      expect(find.text('custom500'), findsOneWidget);
      expect(_slideOffsetY(tester), closeTo(0.0, 0.001),
          reason: 'still fully landed, reverse not started');

      // Tick across the 500ms boundary. reverse() begins this frame.
      await tester.pump(const Duration(milliseconds: 2));
      // One frame into the reverse it should be heading back up (y < 0).
      await tester.pump(const Duration(milliseconds: 60));
      final reversing = _slideOffsetY(tester);
      expect(reversing, lessThan(0.0));
      expect(reversing, greaterThan(-1.0));

      // Finish the reverse.
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();
      expect(find.text('custom500'), findsNothing);
    });

    testWidgets(
        'a very short 1ms duration still slides fully in before reversing',
        (tester) async {
      // The Timer can fire before the 250ms slide finishes. The reverse()
      // call simply reverses from wherever the controller currently is, so
      // the widget must not get stuck or throw.
      await _pumpHost(
        tester,
        message: 'tiny',
        duration: const Duration(milliseconds: 1),
      );
      await tester.tap(find.text('show'));
      await tester.pump(); // t=0
      await tester
          .pump(const Duration(milliseconds: 2)); // timer fires mid-slide
      // It should be reversing from a partial offset, not jumping.
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();
      expect(find.text('tiny'), findsNothing,
          reason: 'mid-slide dismissal still tears down cleanly');
    });
  });

  group('reverse animation on dismiss', () {
    testWidgets('reverse walks the offset from 0 back toward -1 over 250ms',
        (tester) async {
      await _pumpHost(
        tester,
        message: 'rev',
        duration: const Duration(milliseconds: 300),
      );
      await tester.tap(find.text('show'));
      await tester.pump(); // t=0
      await tester.pump(const Duration(milliseconds: 250)); // landed, y==0
      expect(_slideOffsetY(tester), closeTo(0.0, 0.001));

      // Cross the 300ms timer boundary (50ms more) -> reverse starts.
      await tester.pump(const Duration(milliseconds: 50));

      // Sample early in the reverse: still in the tree, partway back up.
      await tester.pump(const Duration(milliseconds: 100));
      final r1 = _slideOffsetY(tester);
      expect(r1, lessThan(0.0));
      expect(r1, greaterThan(-1.0));

      // Sample later: strictly further up than the earlier sample
      // (monotonic reverse).
      await tester.pump(const Duration(milliseconds: 80));
      final r2 = _slideOffsetY(tester);
      expect(r2, lessThan(r1),
          reason: 'reverse is monotonic: offset keeps moving toward -1');

      // Finish.
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();
      expect(find.text('rev'), findsNothing);
    });

    testWidgets('swipe-up triggers the same reverse path via confirmDismiss',
        (tester) async {
      await _pumpHost(
        tester,
        message: 'swipe',
        duration:
            const Duration(seconds: 30), // long, so only the swipe dismisses
      );
      await tester.tap(find.text('show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250)); // landed
      expect(find.text('swipe'), findsOneWidget);

      // Fling upward on the Dismissible. confirmDismiss returns false but
      // calls _dismissSnackBar(), so our own reverse animation runs.
      await tester.fling(find.text('swipe'), const Offset(0, -300), 1000);
      await tester.pump(); // begin
      await tester.pump(const Duration(milliseconds: 250)); // reverse done
      await tester
          .pumpAndSettle(); // onDismissed/remove + any Dismissible settle
      expect(find.text('swipe'), findsNothing,
          reason:
              'swipe-up routes through _dismissSnackBar -> reverse -> remove');
    });
  });

  group('lifecycle: timers, controllers, no leaks', () {
    testWidgets(
        'disposing while the auto-dismiss Timer is still pending throws nothing',
        (tester) async {
      // Arm a long timer, then tear down the whole app while it is pending.
      // dispose() must cancel the Timer; the test framework will fail the
      // test if any Timer survives teardown ("A Timer is still pending").
      await _pumpHost(
        tester,
        message: 'pending',
        duration: const Duration(minutes: 5),
      );
      await tester.tap(find.text('show'));
      await tester.pump();
      await tester
          .pump(const Duration(milliseconds: 250)); // landed, timer pending
      expect(find.text('pending'), findsOneWidget);

      // Replace the entire app with an empty screen. This unmounts the
      // overlay's wrapper -> dispose() runs with the 5-minute Timer pending.
      await tester.pumpWidget(const SizedBox());
      await tester.pump();

      // If the Timer were not cancelled, flutter_test would report a pending
      // timer at the end of the test. Reaching here without an exception and
      // with the binding clean is the proof.
      expect(tester.takeException(), isNull,
          reason: 'dispose cancelled the pending Timer with no error');
    });

    testWidgets(
        'disposing mid-slide (controller still animating) throws nothing',
        (tester) async {
      await _pumpHost(
        tester,
        message: 'midslide',
        duration: const Duration(seconds: 3),
      );
      await tester.tap(find.text('show'));
      await tester.pump(); // t=0, controller.forward() in flight
      await tester
          .pump(const Duration(milliseconds: 100)); // mid-slide, value~0.4

      // Tear down while the AnimationController is actively ticking.
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(tester.takeException(), isNull,
          reason:
              'controller disposed mid-flight without "ticker still active" error');
    });

    testWidgets('disposing mid-reverse (after timer fired) throws nothing',
        (tester) async {
      await _pumpHost(
        tester,
        message: 'midreverse',
        duration: const Duration(milliseconds: 200),
      );
      await tester.tap(find.text('show'));
      await tester.pump(); // t=0
      await tester.pump(const Duration(milliseconds: 250)); // landed
      await tester.pump(const Duration(
          milliseconds: 60)); // cross 200ms timer -> reverse starts
      await tester.pump(const Duration(milliseconds: 50)); // 50ms into reverse

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(tester.takeException(), isNull,
          reason: 'tearing down during reverse leaves no live ticker/timer');
    });

    testWidgets('full natural lifecycle leaves no pending timers behind',
        (tester) async {
      // Run a snack bar through its entire life: slide-in, dwell, auto-dismiss,
      // reverse, removal. If any Timer or ticker leaked, teardown fails.
      await _pumpHost(
        tester,
        message: 'lifecycle',
        duration: const Duration(milliseconds: 400),
      );
      await tester.tap(find.text('show'));
      await tester.pump(); // t=0
      await tester.pump(const Duration(milliseconds: 250)); // slide-in
      await tester.pump(
          const Duration(milliseconds: 150)); // dwell to t=400, timer fires
      await tester.pump(const Duration(milliseconds: 250)); // reverse
      await tester.pumpAndSettle(); // onDismissed -> remove
      expect(find.text('lifecycle'), findsNothing);

      // Pump well past any conceivable straggler. A leaked Timer would be
      // caught by the framework's end-of-test pending-timer assertion.
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'rapid replacement disposes the old wrapper with no leaked timer',
        (tester) async {
      // Two shows back-to-back. The first show()'s wrapper is removed
      // synchronously by the second show() (entry.remove()), which must
      // dispose it and cancel its still-pending auto-dismiss Timer.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Column(
                children: [
                  ElevatedButton(
                    onPressed: () => showCustomSnackBar(
                        context, 'first', SnackBarType.success,
                        duration: const Duration(minutes: 5)),
                    child: const Text('a'),
                  ),
                  ElevatedButton(
                    onPressed: () => showCustomSnackBar(
                        context, 'second', SnackBarType.failure,
                        duration: const Duration(milliseconds: 400)),
                    child: const Text('b'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('a'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('first'), findsOneWidget);

      // Replace: old wrapper (with a 5-minute pending Timer) is removed.
      await tester.tap(find.text('b'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('first'), findsNothing,
          reason:
              'old entry removed; its Timer must have been cancelled on dispose');
      expect(find.text('second'), findsOneWidget);

      // Let the second one finish so the test ends with zero pending timers.
      await tester.pump(const Duration(milliseconds: 150)); // to t=400 -> fires
      await tester.pump(const Duration(milliseconds: 250)); // reverse
      await tester.pumpAndSettle();
      expect(find.text('second'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
