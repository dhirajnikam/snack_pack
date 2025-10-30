import 'package:flutter/material.dart';

/// Configuration for responsive layout and positioning.
class SnackPackConfig {
  /// Width breakpoint at or above which the snack bar is shown at the top-right.
  final double largeBreakpoint;

  /// Maximum width of the snack bar on large screens.
  final double maxWidthOnLarge;

  /// Outer padding from screen edges.
  final EdgeInsets margin;

  const SnackPackConfig({
    this.largeBreakpoint = 1024,
    this.maxWidthOnLarge = 420,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  });

  static const SnackPackConfig defaults = SnackPackConfig();
}

/// Enum representing the type of snack bar to display.
///
/// Each type has a distinct color and icon to convey the message's intent.
enum SnackBarType {
  /// Success message (green with check icon)
  success,

  /// Failure/Error message (red with error icon)
  failure,

  /// Warning message (orange with warning icon)
  warning,

  /// Informational message (blue with info icon)
  info,
}

// Global variable to track the current snack bar overlay.
OverlayEntry? _currentSnackBarEntry;

/// Displays a custom animated snack bar at the top of the screen.
///
/// This function shows a dismissible snack bar that slides in from the top
/// and automatically dismisses after the specified [duration]. Only one snack
/// bar is shown at a time; showing a new one will dismiss the previous one.
///
/// Example:
/// ```dart
/// showCustomSnackBar(
///   context,
///   'Operation completed successfully!',
///   SnackBarType.success,
/// );
/// ```
///
/// Parameters:
/// - [context]: The build context used to access the overlay
/// - [message]: The message text to display
/// - [type]: The type of snack bar (success, failure, warning, or info)
/// - [duration]: How long the snack bar stays visible (default: 3 seconds)
void showCustomSnackBar(
  BuildContext context,
  String message,
  SnackBarType type, {
  Duration duration = const Duration(seconds: 3),
  SnackPackConfig config = SnackPackConfig.defaults,
}) {
  final overlay = Overlay.of(context);

  // Remove the currently visible snack bar if it exists.
  _currentSnackBarEntry?.remove();
  _currentSnackBarEntry = null;

  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) => _TopSnackBarWrapper(
      message: message,
      type: type,
      duration: duration,
      config: config,
      onDismissed: () {
        overlayEntry.remove();
        // Clear the global reference if it points to this overlay.
        if (_currentSnackBarEntry == overlayEntry) {
          _currentSnackBarEntry = null;
        }
      },
    ),
  );
  _currentSnackBarEntry = overlayEntry;
  overlay.insert(overlayEntry);
}

/// Internal widget that wraps the snack bar with animation and dismissal logic.
class _TopSnackBarWrapper extends StatefulWidget {
  final String message;
  final SnackBarType type;
  final Duration duration;
  final VoidCallback onDismissed;
  final SnackPackConfig config;

  const _TopSnackBarWrapper({
    required this.message,
    required this.type,
    required this.duration,
    required this.config,
    required this.onDismissed,
  });

  @override
  _TopSnackBarWrapperState createState() => _TopSnackBarWrapperState();
}

class _TopSnackBarWrapperState extends State<_TopSnackBarWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Slide the snack bar into view.
    _controller.forward();

    // Auto-dismiss after the specified duration.
    Future.delayed(widget.duration, () {
      if (!_isDismissed && mounted) {
        _dismissSnackBar();
      }
    });
  }

  /// Dismisses the snack bar with a reverse animation.
  void _dismissSnackBar() {
    if (!_isDismissed && mounted) {
      _isDismissed = true;
      _controller.reverse().then((_) {
        if (mounted) {
          widget.onDismissed();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Returns the appropriate color based on the snack bar type.
  Color _getColorByType(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Colors.green;
      case SnackBarType.failure:
        return Colors.red;
      case SnackBarType.warning:
        return Colors.orange;
      case SnackBarType.info:
        return Colors.blue;
    }
  }

  /// Returns the appropriate icon based on the snack bar type.
  IconData _getIconByType(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle;
      case SnackBarType.failure:
        return Icons.error;
      case SnackBarType.warning:
        return Icons.warning;
      case SnackBarType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topInset = mediaQuery.padding.top + widget.config.margin.top;
    final isLarge = mediaQuery.size.width >= widget.config.largeBreakpoint;

    final horizontalMargin = EdgeInsets.only(
      left: isLarge ? 0 : widget.config.margin.left,
      right: widget.config.margin.right,
    );

    Widget content = Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.up,
      // Intercept the swipe and trigger our custom animation.
      confirmDismiss: (direction) async {
        _dismissSnackBar();
        return false;
      },
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(8),
          color: _getColorByType(widget.type).withOpacity(0.9),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                Icon(_getIconByType(widget.type), color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (isLarge) {
      // Constrain width and align to top-right on large screens.
      final maxWidth = widget.config.maxWidthOnLarge;
      content = Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: horizontalMargin,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
            ),
            child: content,
          ),
        ),
      );

      return Positioned(
        top: topInset,
        right: 0,
        child: content,
      );
    }

    // Default: full-width (minus margins) top-aligned on smaller screens.
    return Positioned(
      top: topInset,
      left: widget.config.margin.left,
      right: widget.config.margin.right,
      child: content,
    );
  }
}
