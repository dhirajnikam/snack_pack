// w1 — Core rendering & type-correctness tests.
//
// Author: edsger-dijkstra
//
// Methodological note. "Program testing can be used to show the presence of
// bugs, but never to show their absence." We therefore do not write smoke
// checks that merely confirm "something rendered". Each test below fixes a
// *precise, named invariant* and asserts it directly against the rendered
// widget tree. Where a property ranges over a domain (here: the four
// SnackBarType values), we discharge the obligation exhaustively rather than
// for a single representative, so the proof covers the whole domain.
//
// The library exposes only `showCustomSnackBar`, `SnackBarType`, and
// `SnackPackConfig`. The colour/icon mapping lives in a *private* widget, so
// we cannot inspect it by reflection. Instead we restate the intended mapping
// in a local oracle and verify the rendered Material.color / Icon against it.
// If the oracle and the implementation ever diverge, a test fails — which is
// exactly the contract we want to enforce.
//
// Style: local type annotations are omitted where inference is unambiguous, to
// satisfy the project's `omit_local_variable_types` lint (the agreed gate).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snack_pack/snack_pack.dart';

/// The intended (type -> base colour) mapping, restated independently of the
/// implementation. The rendered Material paints this colour at 0.9 opacity.
const _expectedBaseColor = <SnackBarType, Color>{
  SnackBarType.success: Colors.green,
  SnackBarType.failure: Colors.red,
  SnackBarType.warning: Colors.orange,
  SnackBarType.info: Colors.blue,
};

/// The intended (type -> icon) mapping, restated independently.
const _expectedIcon = <SnackBarType, IconData>{
  SnackBarType.success: Icons.check_circle,
  SnackBarType.failure: Icons.error,
  SnackBarType.warning: Icons.warning,
  SnackBarType.info: Icons.info,
};

/// Builds a host app exposing a single trigger button that shows a snack bar of
/// the given [type] carrying [message]. Centralising the harness keeps each
/// test focused on the property it asserts (DRY over the setup, precise over
/// the assertion).
Widget _host({
  required String message,
  required SnackBarType type,
  Duration duration = const Duration(seconds: 3),
  SnackPackConfig config = SnackPackConfig.defaults,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showCustomSnackBar(
            context,
            message,
            type,
            duration: duration,
            config: config,
          ),
          child: const Text('trigger'),
        ),
      ),
    ),
  );
}

/// Pumps the host, fires the trigger, and lets the slide-in animation settle.
/// Post-condition: the snack bar is fully on screen and static.
Future<void> _showAndSettle(WidgetTester tester, Widget app) async {
  await tester.pumpWidget(app);
  await tester.tap(find.text('trigger'));
  await tester.pumpAndSettle();
}

/// Locates the single Material that *is* the snack bar surface: the one whose
/// child subtree contains the message Row. We deliberately do not assume it is
/// the only Material in the tree (the ElevatedButton contributes Materials),
/// so we select by structural role rather than by count of all Materials.
Material _snackBarMaterial(WidgetTester tester, String message) {
  // The message Text is unique; walk up to the enclosing Material.
  final material = find.ancestor(
    of: find.text(message),
    matching: find.byType(Material),
  );
  expect(material, findsWidgets,
      reason: 'message must live inside a Material surface');
  // The innermost ancestor Material is the snack bar surface.
  return tester.widget<Material>(material.first);
}

void main() {
  // ---------------------------------------------------------------------------
  // Domain-exhaustive invariant: for EVERY SnackBarType, the rendered snack bar
  // simultaneously exhibits (a) the message, (b) the correct icon, (c) the
  // correct base colour. Quantifier: ∀ t ∈ SnackBarType.values.
  // ---------------------------------------------------------------------------
  group('Per-type rendering invariant (forall type)', () {
    // Guard: the test domain must equal the implementation domain. If a new
    // type is added without extending the oracles, this fails loudly rather
    // than silently skipping the new case.
    test('oracles cover exactly the SnackBarType domain', () {
      expect(_expectedBaseColor.keys.toSet(), SnackBarType.values.toSet());
      expect(_expectedIcon.keys.toSet(), SnackBarType.values.toSet());
      expect(SnackBarType.values.length, 4);
    });

    for (final type in SnackBarType.values) {
      testWidgets('type=$type renders message, icon, and base colour',
          (tester) async {
        final message = 'msg-${type.name}';
        await _showAndSettle(tester, _host(message: message, type: type));

        // (a) message text present exactly once.
        expect(find.text(message), findsOneWidget);

        // (b) the type's icon present exactly once; no *other* type's icon
        //     leaks into the tree.
        expect(find.byIcon(_expectedIcon[type]!), findsOneWidget);
        for (final other in SnackBarType.values) {
          if (other == type) {
            continue;
          }
          expect(find.byIcon(_expectedIcon[other]!), findsNothing,
              reason: 'icon for $other must not appear when showing $type');
        }

        // (c) base colour: the Material paints the expected colour at 0.9
        //     opacity. We compare against the oracle's colour withOpacity(0.9)
        //     to pin the exact rendered value, not merely "some colour".
        final surface = _snackBarMaterial(tester, message);
        // ignore: deprecated_member_use
        final expected = _expectedBaseColor[type]!.withOpacity(0.9);
        expect(surface.color, isNotNull);
        // Compare Color objects directly: Color equality is value-based and
        // stable across Flutter versions (unlike toARGB32, which is 3.27+).
        expect(surface.color, expected,
            reason: 'surface colour must be ${type.name} @ 0.9 opacity');
      });
    }
  });

  // ---------------------------------------------------------------------------
  // Structural invariants of the rendered surface. These hold independently of
  // type, so we fix a representative (success) and assert the shape precisely.
  // ---------------------------------------------------------------------------
  group('Structural invariants of the snack bar surface', () {
    const message = 'structure-probe';

    testWidgets('overlay inserts the message into the live tree',
        (tester) async {
      await _showAndSettle(
          tester, _host(message: message, type: SnackBarType.info));
      // The snack bar is rendered via an OverlayEntry; its content must be
      // findable, proving the entry was actually inserted and built.
      expect(find.text(message), findsOneWidget);
    });

    testWidgets(
        'surface is a Material with elevation 6 and 8px rounded corners',
        (tester) async {
      await _showAndSettle(
          tester, _host(message: message, type: SnackBarType.success));
      final surface = _snackBarMaterial(tester, message);
      expect(surface.elevation, 6.0);
      expect(surface.borderRadius, BorderRadius.circular(8));
    });

    testWidgets('content is exactly one Row holding Icon then Text, in order',
        (tester) async {
      await _showAndSettle(
          tester, _host(message: message, type: SnackBarType.warning));

      // The message Row is the Row that contains the message Text. Exactly one
      // such Row exists (the snack bar's content row).
      final messageRow = find.ancestor(
        of: find.text(message),
        matching: find.byType(Row),
      );
      expect(messageRow, findsOneWidget);

      // Within that Row, the Icon must precede the Text. We assert ordering by
      // comparing their laid-out positions: the Icon's render box must sit to
      // the left of the Text's render box.
      final iconLeft = tester.getTopLeft(
        find.descendant(
          of: messageRow,
          matching: find.byType(Icon),
        ),
      );
      final textLeft = tester.getTopLeft(
        find.descendant(
          of: messageRow,
          matching: find.text(message),
        ),
      );
      expect(iconLeft.dx, lessThan(textLeft.dx),
          reason: 'Icon must be laid out before (left of) the message Text');
    });

    testWidgets('message Text is wrapped in Expanded so it can flex/wrap',
        (tester) async {
      await _showAndSettle(
          tester, _host(message: message, type: SnackBarType.failure));
      final expandedAroundText = find.ancestor(
        of: find.text(message),
        matching: find.byType(Expanded),
      );
      expect(expandedAroundText, findsOneWidget,
          reason: 'long messages rely on Expanded to avoid overflow');
    });

    testWidgets('foreground (icon + text) is rendered white', (tester) async {
      await _showAndSettle(
          tester, _host(message: message, type: SnackBarType.info));

      // Icon colour is white.
      final icon = tester.widget<Icon>(
        find.descendant(
          of: find.ancestor(of: find.text(message), matching: find.byType(Row)),
          matching: find.byType(Icon),
        ),
      );
      expect(icon.color, Colors.white);

      // Text style colour is white.
      final text = tester.widget<Text>(find.text(message));
      expect(text.style?.color, Colors.white);
    });

    testWidgets('surface is animated via a SlideTransition', (tester) async {
      await _showAndSettle(
          tester, _host(message: message, type: SnackBarType.success));
      // The message must live inside a SlideTransition — the mechanism that
      // realises the slide-in. (Its *timing* is w2's concern; here we only
      // assert the structural presence.) Note: more than one SlideTransition
      // may enclose the message — the overlay/route machinery contributes its
      // own. The invariant entailed by the source is therefore "at least one",
      // and we additionally pin that one of them rests at Offset.zero once
      // settled, i.e. the slide-in has completed and the surface is in place.
      final slides = find.ancestor(
        of: find.text(message),
        matching: find.byType(SlideTransition),
      );
      expect(slides, findsWidgets);

      final hasSettledSlide = tester
          .widgetList<SlideTransition>(slides)
          .any((s) => s.position.value == Offset.zero);
      expect(hasSettledSlide, isTrue,
          reason: 'a SlideTransition must rest at Offset.zero once settled');
    });
  });

  // ---------------------------------------------------------------------------
  // Positioning invariant (default config, small screen). The snack bar must be
  // top-anchored. We assert the content sits within the top half of the screen
  // — a precise placement property, not a vague "it's somewhere on screen".
  // ---------------------------------------------------------------------------
  group('Top-anchored placement (default small-screen layout)', () {
    testWidgets('content is anchored to the top region of the viewport',
        (tester) async {
      const message = 'top-anchor-probe';
      await _showAndSettle(
          tester, _host(message: message, type: SnackBarType.info));

      final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
      final topLeft = tester.getTopLeft(find.text(message));
      expect(topLeft.dy, lessThan(screen.height / 2),
          reason: 'snack bar must be anchored to the top half of the screen');
    });
  });

  // ---------------------------------------------------------------------------
  // Argument fidelity: the exact message string is rendered verbatim, including
  // whitespace and unicode, with no truncation/transformation at render time.
  // ---------------------------------------------------------------------------
  group('Message fidelity', () {
    testWidgets('renders the message string verbatim (unicode + spaces)',
        (tester) async {
      const message = '  Cafe — 日本語 — check  ';
      await _showAndSettle(
          tester, _host(message: message, type: SnackBarType.success));
      expect(find.text(message), findsOneWidget);
      final text = tester.widget<Text>(find.text(message));
      expect(text.data, message);
    });
  });
}
