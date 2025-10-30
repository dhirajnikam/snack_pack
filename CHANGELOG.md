# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2025-10-30

### Fixed
- Fixed timer disposal logic in the snack bar auto-dismiss. Cancels timers on widget disposal. Prevents test and runtime disposal/pending timer errors.
- Improved test reliability: All widget tests now pass and are robust for overlays/animations.

### Improved
- Example is now at `example/main.dart` so the Example section appears on pub.dev.
- CI/CD and publishing workflow clarification.

## [1.0.0] - 2025-10-29

### Added
- Initial release of Snack Pack
- Four built-in snack bar types: success, failure, warning, and info
- Smooth slide-in and slide-out animations
- Swipe-to-dismiss functionality
- Auto-dismiss with customizable duration
- Smart queue management (only one snack bar visible at a time)
- Safe area awareness for device notches and status bars
- Comprehensive documentation and examples
- Full platform support (Android, iOS, Web, macOS, Windows, Linux)

### Features
- `showCustomSnackBar()` function for easy display of snack bars
- `SnackBarType` enum with four distinct types
- Customizable duration parameter
- Material Design-inspired UI with elevation and rounded corners
- Type-specific icons and colors
- Responsive layout that adapts to screen width

### Documentation
- Complete README with usage examples
- API reference documentation
- In-code documentation for all public APIs
- Example application demonstrating all features
