// Responsive layout & API contract tests for snack_pack.
//
// Author: barbara-liskov (peer w4).
//
// Philosophy: SnackPackConfig is a public interface. These tests treat it as a
// contract and verify that the documented behavior holds across the FULL range
// of configuration. The Liskov substitution view: any well-formed
// SnackPackConfig substituted into showCustomSnackBar must preserve the same
// layout invariants -- only the parameters (breakpoint, max width, margins)
// change, never the shape of the guarantee.
//
// The layout contract, read off lib/src/snack_pack.dart:
//
//   isLarge  := mediaQuery.size.width >= config.largeBreakpoint
//   topInset := mediaQuery.padding.top + config.margin.top
//
//   isLarge == true  -> Positioned(top: topInset, right: 0) wrapping
//                       Align(topRight) > ConstrainedBox(maxWidth: maxWidthOnLarge)
//   isLarge == false -> Positioned(top: topInset,
//                                  left: margin.left, right: margin.right)
//
// We never inspect private internals; we assert against the public widget tree
// (Positioned / Align / ConstrainedBox) that the overlay produces. That is the
// observable surface of the contract.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snack_pack/snack_pack.dart';

/// Pumps an app whose Builder, when its button is tapped, shows a snack bar
/// with the given [type], [duration] and [config]. Returns nothing; the caller
/// taps the 'show' button and pumps.
///
/// Note on safe-area insets: the snack bar's overlay lives inside MaterialApp's
/// Navigator, so it reads the *root* MediaQuery, not one we inject below
/// MaterialApp. To exercise padding.top we therefore drive the physical view's
/// padding (see [_setLogicalSize]), which the root MediaQuery surfaces.
Future<void> _pumpHost(
  WidgetTester tester, {
  required String message,
  SnackBarType type = SnackBarType.info,
  Duration duration = const Duration(seconds: 3),
  SnackPackConfig config = SnackPackConfig.defaults,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            return ElevatedButton(
              onPressed: () {
                showCustomSnackBar(
                  context,
                  message,
                  type,
                  duration: duration,
                  config: config,
                );
              },
              child: const Text('show'),
            );
          },
        ),
      ),
    ),
  );
}

/// Sets the logical screen width/height (and optional top safe-area inset) by
/// driving the physical view, and registers tear-downs so tests stay isolated.
///
/// [topPadding] is a *logical* inset; we scale it by the devicePixelRatio (1.0
/// here) into physical pixels for the view's padding/viewPadding.
void _setLogicalSize(
  WidgetTester tester,
  double width,
  double height, {
  double topPadding = 0,
}) {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = ui.Size(width, height);
  if (topPadding > 0) {
    final fakePadding = FakeViewPadding(top: topPadding);
    tester.view.padding = fakePadding;
    tester.view.viewPadding = fakePadding;
  }
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.view.resetPadding();
    tester.view.resetViewPadding();
  });
}

/// Locates the [Positioned] that the snack bar overlay wraps its content in.
/// There is exactly one in the overlay tree produced by the wrapper.
Positioned _findSnackPositioned(WidgetTester tester) {
  final positions =
      tester.widgetList<Positioned>(find.byType(Positioned)).toList();
  // The overlay's Positioned is the one whose subtree contains our Material
  // message. Filter to the Positioned that is an ancestor of the SlideTransition.
  final matching = positions.where((p) {
    return find
        .descendant(
          of: find.byWidget(p),
          matching: find.byType(SlideTransition),
        )
        .evaluate()
        .isNotEmpty;
  }).toList();
  expect(matching, hasLength(1),
      reason: 'expected exactly one snack bar Positioned in the overlay');
  return matching.single;
}

/// Decides which layout branch the contract took, purely from the snack bar's
/// own [Positioned] geometry -- the observable contract surface:
///   large  => pinned to the right edge (right == 0) with no left;
///   small  => spans with explicit left and right margins.
/// This is more robust than counting Align ancestors (MaterialApp injects its
/// own Aligns) and asserts exactly the property callers care about.
bool _isLargeLayout(WidgetTester tester) {
  final pos = _findSnackPositioned(tester);
  final large = pos.right == 0 && pos.left == null;
  // Sanity: the two branches are mutually exclusive on left.
  if (!large) {
    expect(pos.left, isNotNull,
        reason: 'small branch must set an explicit left margin');
  }
  return large;
}

void main() {
  // ---------------------------------------------------------------------------
  // 1. SnackPackConfig defaults -- the documented default contract.
  // ---------------------------------------------------------------------------
  group('SnackPackConfig contract: defaults', () {
    test('default constructor exposes the documented default values', () {
      const config = SnackPackConfig();
      expect(config.largeBreakpoint, 1024,
          reason: 'documented default largeBreakpoint');
      expect(config.maxWidthOnLarge, 420,
          reason: 'documented default maxWidthOnLarge');
      expect(config.margin,
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          reason: 'documented default margin');
    });

    test('SnackPackConfig.defaults equals a freshly constructed default', () {
      const fresh = SnackPackConfig();
      expect(SnackPackConfig.defaults.largeBreakpoint, fresh.largeBreakpoint);
      expect(SnackPackConfig.defaults.maxWidthOnLarge, fresh.maxWidthOnLarge);
      expect(SnackPackConfig.defaults.margin, fresh.margin);
    });

    test('config is const-constructible (compile-time stable interface)', () {
      // If this compiles, the public constructor remains const -- a property
      // callers may depend on (e.g. default arg values).
      const a = SnackPackConfig(largeBreakpoint: 800);
      const b = SnackPackConfig(largeBreakpoint: 800);
      expect(identical(a, b), isTrue,
          reason: 'identical const instances should be canonicalized');
    });

    test('custom values are stored verbatim on the interface', () {
      const config = SnackPackConfig(
        largeBreakpoint: 700,
        maxWidthOnLarge: 320,
        margin: EdgeInsets.all(24),
      );
      expect(config.largeBreakpoint, 700);
      expect(config.maxWidthOnLarge, 320);
      expect(config.margin, const EdgeInsets.all(24));
    });
  });

  // ---------------------------------------------------------------------------
  // 2. Large-screen placement: top-right, width-constrained.
  // ---------------------------------------------------------------------------
  group('large-screen contract (width >= largeBreakpoint)', () {
    testWidgets('places snack bar top-right with maxWidthOnLarge constraint',
        (WidgetTester tester) async {
      _setLogicalSize(tester, 1400, 900); // >= default 1024

      await _pumpHost(tester, message: 'large screen');
      await tester.tap(find.text('show'));
      await tester.pumpAndSettle();

      expect(find.text('large screen'), findsOneWidget);

      // Contract: large layout (top-right, right-pinned).
      expect(_isLargeLayout(tester), isTrue,
          reason: 'wide screen must take the large branch');

      // Contract: a top-right Align wraps the content. We scope to topRight so
      // MaterialApp's own internal Aligns don't confuse the assertion.
      final topRightAligns = tester
          .widgetList<Align>(find.byType(Align))
          .where((a) => a.alignment == Alignment.topRight)
          .toList();
      expect(topRightAligns, isNotEmpty,
          reason: 'large screens align content to top-right');

      // Contract: width is constrained to maxWidthOnLarge (default 420).
      final constrained = tester.widget<ConstrainedBox>(
        find
            .ancestor(
              of: find.byType(SlideTransition),
              matching: find.byType(ConstrainedBox),
            )
            .first,
      );
      expect(constrained.constraints.maxWidth, 420,
          reason: 'default maxWidthOnLarge constraint');

      // Contract: Positioned pins to the right edge (right == 0).
      final pos = _findSnackPositioned(tester);
      expect(pos.right, 0, reason: 'large screen pins to right: 0');
      expect(pos.left, isNull, reason: 'large screen does not set left');
    });

    testWidgets(
        'substituting a different maxWidthOnLarge tracks the constraint',
        (WidgetTester tester) async {
      _setLogicalSize(tester, 1400, 900);

      const config = SnackPackConfig(maxWidthOnLarge: 250);
      await _pumpHost(tester, message: 'narrow large', config: config);
      await tester.tap(find.text('show'));
      await tester.pumpAndSettle();

      final constrained = tester.widget<ConstrainedBox>(
        find
            .ancestor(
              of: find.byType(SlideTransition),
              matching: find.byType(ConstrainedBox),
            )
            .first,
      );
      // Invariant preserved under substitution: constraint == config value.
      expect(constrained.constraints.maxWidth, 250);
    });
  });

  // ---------------------------------------------------------------------------
  // 3. Small-screen placement: full width minus margins.
  // ---------------------------------------------------------------------------
  group('small-screen contract (width < largeBreakpoint)', () {
    testWidgets('places snack bar full-width with left/right margins',
        (WidgetTester tester) async {
      _setLogicalSize(tester, 400, 800); // < default 1024

      await _pumpHost(tester, message: 'small screen');
      await tester.tap(find.text('show'));
      await tester.pumpAndSettle();

      expect(find.text('small screen'), findsOneWidget);

      // Contract: small layout (spans with margins, not right-pinned).
      expect(_isLargeLayout(tester), isFalse,
          reason: 'narrow screen must take the small branch');

      // Contract: Positioned spans with left == margin.left, right == margin.right.
      final pos = _findSnackPositioned(tester);
      expect(pos.left, 16, reason: 'default margin.left');
      expect(pos.right, 16, reason: 'default margin.right');
    });

    testWidgets('boundary: width exactly at breakpoint counts as large',
        (WidgetTester tester) async {
      // Contract uses >= , so width == largeBreakpoint must be the large branch.
      _setLogicalSize(tester, 1024, 800);

      await _pumpHost(tester, message: 'boundary');
      await tester.tap(find.text('show'));
      await tester.pumpAndSettle();

      expect(_isLargeLayout(tester), isTrue,
          reason: 'width == breakpoint is inclusive (>=) -> large branch');
    });

    testWidgets('boundary: one logical pixel below breakpoint is small',
        (WidgetTester tester) async {
      _setLogicalSize(tester, 1023, 800);

      await _pumpHost(tester, message: 'just below');
      await tester.tap(find.text('show'));
      await tester.pumpAndSettle();

      expect(_isLargeLayout(tester), isFalse,
          reason: 'width just below breakpoint -> small branch');
    });
  });

  // ---------------------------------------------------------------------------
  // 4. Custom breakpoints/margins -- substitution preserves the invariant.
  // ---------------------------------------------------------------------------
  group('custom config substitution preserves layout invariants', () {
    testWidgets('a lowered breakpoint flips a mid-size screen to large',
        (WidgetTester tester) async {
      // 800px screen: large under a 700 breakpoint, small under default 1024.
      _setLogicalSize(tester, 800, 600);

      const config = SnackPackConfig(largeBreakpoint: 700);
      await _pumpHost(tester, message: 'lowered bp', config: config);
      await tester.tap(find.text('show'));
      await tester.pumpAndSettle();

      expect(_isLargeLayout(tester), isTrue,
          reason: '800 >= custom breakpoint 700 -> large');
    });

    testWidgets('a raised breakpoint keeps a wide screen small',
        (WidgetTester tester) async {
      _setLogicalSize(tester, 1400, 900);

      const config = SnackPackConfig(largeBreakpoint: 2000);
      await _pumpHost(tester, message: 'raised bp', config: config);
      await tester.tap(find.text('show'));
      await tester.pumpAndSettle();

      expect(_isLargeLayout(tester), isFalse,
          reason: '1400 < custom breakpoint 2000 -> small');
    });

    testWidgets('custom margins flow into the small-screen Positioned',
        (WidgetTester tester) async {
      _setLogicalSize(tester, 400, 800);

      const config = SnackPackConfig(
        margin: EdgeInsets.only(left: 30, right: 40, top: 10),
      );
      await _pumpHost(tester, message: 'custom margins', config: config);
      await tester.tap(find.text('show'));
      await tester.pumpAndSettle();

      final pos = _findSnackPositioned(tester);
      expect(pos.left, 30,
          reason: 'custom margin.left flows to Positioned.left');
      expect(pos.right, 40,
          reason: 'custom margin.right flows to Positioned.right');
    });

    testWidgets('custom maxWidthOnLarge flows into the large-screen constraint',
        (WidgetTester tester) async {
      _setLogicalSize(tester, 1400, 900);

      const config = SnackPackConfig(maxWidthOnLarge: 600);
      await _pumpHost(tester, message: 'wide cap', config: config);
      await tester.tap(find.text('show'));
      await tester.pumpAndSettle();

      final constrained = tester.widget<ConstrainedBox>(
        find
            .ancestor(
              of: find.byType(SlideTransition),
              matching: find.byType(ConstrainedBox),
            )
            .first,
      );
      expect(constrained.constraints.maxWidth, 600);
    });
  });

  // ---------------------------------------------------------------------------
  // 5. Safe-area top inset: topInset == padding.top + margin.top.
  // ---------------------------------------------------------------------------
  group('safe-area top inset contract', () {
    testWidgets('small screen: Positioned.top == padding.top + margin.top',
        (WidgetTester tester) async {
      // Inject a 44px status-bar style top inset via the physical view.
      _setLogicalSize(tester, 400, 800, topPadding: 44);

      await _pumpHost(tester, message: 'inset small');
      await tester.tap(find.text('show'));
      await tester.pumpAndSettle();

      final pos = _findSnackPositioned(tester);
      // default margin.top == 16; padding.top == 44 => 60.
      expect(pos.top, 44 + 16,
          reason: 'topInset = padding.top(44) + margin.top(16)');
    });

    testWidgets('large screen: Positioned.top also honours the top inset',
        (WidgetTester tester) async {
      _setLogicalSize(tester, 1400, 900, topPadding: 24);

      await _pumpHost(tester, message: 'inset large');
      await tester.tap(find.text('show'));
      await tester.pumpAndSettle();

      final pos = _findSnackPositioned(tester);
      expect(pos.top, 24 + 16,
          reason: 'topInset = padding.top(24) + margin.top(16) on large too');
    });

    testWidgets('custom margin.top participates in the inset sum',
        (WidgetTester tester) async {
      _setLogicalSize(tester, 400, 800, topPadding: 50);

      const config = SnackPackConfig(
        margin: EdgeInsets.only(left: 16, right: 16, top: 8),
      );
      await _pumpHost(tester, message: 'custom top', config: config);
      await tester.tap(find.text('show'));
      await tester.pumpAndSettle();

      final pos = _findSnackPositioned(tester);
      expect(pos.top, 50 + 8,
          reason: 'topInset = padding.top(50) + custom margin.top(8)');
    });

    testWidgets('zero inset: top == margin.top alone',
        (WidgetTester tester) async {
      _setLogicalSize(tester, 400, 800); // no top padding

      await _pumpHost(tester, message: 'no inset');
      await tester.tap(find.text('show'));
      await tester.pumpAndSettle();

      final pos = _findSnackPositioned(tester);
      expect(pos.top, 16, reason: 'no padding -> top == margin.top(16)');
    });
  });
}
