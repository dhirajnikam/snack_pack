/// A beautiful and customizable animated snack bar package for Flutter.
///
/// This package provides an easy way to display top-aligned snack bars with
/// smooth animations and swipe-to-dismiss functionality.
///
/// ## Features
///
/// - Four built-in types: success, failure, warning, and info
/// - Smooth slide-in and slide-out animations
/// - Swipe up to dismiss
/// - Auto-dismiss with customizable duration
/// - Only one snack bar visible at a time
/// - Respects safe area (notches and status bars)
///
/// ## Usage
///
/// ```dart
/// import 'package:snack_pack/snack_pack.dart';
///
/// showCustomSnackBar(
///   context,
///   'This is a success message!',
///   SnackBarType.success,
/// );
/// ```
library snack_pack;

export 'src/snack_pack.dart';
