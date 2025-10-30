# 🍿 Snack Pack

[![pub package](https://img.shields.io/pub/v/snack_pack.svg)](https://pub.dev/packages/snack_pack)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-android%20|%20ios%20|%20web%20|%20macos%20|%20windows%20|%20linux-lightgrey)](https://pub.dev/packages/snack_pack)

A beautiful and customizable animated snack bar package for Flutter. Display top-aligned snack bars with smooth animations, swipe-to-dismiss functionality, and responsive positioning that adapts to any screen size.

## Why Snack Pack?

Unlike Flutter's built-in `SnackBar` which appears at the bottom, Snack Pack provides **top-aligned notifications** that are more noticeable and don't interfere with bottom navigation or floating action buttons. Perfect for modern app UIs!

## Features

- **Four Built-in Types**: Success, Failure, Warning, and Info with distinct colors and icons
- **Smooth Animations**: Slide-in and slide-out animations with customizable curves
- **Swipe to Dismiss**: Users can swipe up to dismiss the snack bar instantly
- **Auto-Dismiss**: Automatically dismisses after a customizable duration
- **Smart Queue Management**: Only one snack bar visible at a time - no overlapping notifications
- **Responsive Design**: Adapts to screen size - full-width on mobile, top-right corner on large screens
- **Safe Area Aware**: Respects device notches, status bars, and safe areas
- **Lightweight**: Minimal dependencies, just Flutter SDK
- **Highly Customizable**: Configure positioning, duration, and responsive breakpoints
- **Easy to Use**: Simple API with sensible defaults - get started in seconds

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  snack_pack: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

Get up and running in just 3 steps:

```dart
// 1. Import the package
import 'package:snack_pack/snack_pack.dart';

// 2. Call showCustomSnackBar anywhere you have a BuildContext
showCustomSnackBar(
  context,
  'Hello, Snack Pack!',
  SnackBarType.success,
);

// 3. That's it! The snack bar will automatically appear and dismiss
```

## Usage

Import the package:

```dart
import 'package:snack_pack/snack_pack.dart';
```

### Basic Usage

```dart
showCustomSnackBar(
  context,
  'This is a success message!',
  SnackBarType.success,
);
```

### With Custom Duration

```dart
showCustomSnackBar(
  context,
  'This warning will stay for 5 seconds',
  SnackBarType.warning,
  duration: const Duration(seconds: 5),
);
```

### Responsive Positioning (Top-right on large screens)

By default, on large screens (≥1024 logical px), Snack Pack constrains width and aligns the snack bar to the top-right. You can override breakpoints and sizing with `SnackPackConfig`:

```dart
showCustomSnackBar(
  context,
  'Custom layout on large screens',
  SnackBarType.info,
  config: const SnackPackConfig(
    largeBreakpoint: 1200, // treat screens ≥1200 as large
    maxWidthOnLarge: 480,  // limit width on large screens
    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
  ),
);
```

### All Types

```dart
// Success
showCustomSnackBar(
  context,
  'Operation completed successfully!',
  SnackBarType.success,
);

// Failure
showCustomSnackBar(
  context,
  'Something went wrong!',
  SnackBarType.failure,
);

// Warning
showCustomSnackBar(
  context,
  'Please check your input',
  SnackBarType.warning,
);

// Info
showCustomSnackBar(
  context,
  'Did you know?',
  SnackBarType.info,
);
```

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:snack_pack/snack_pack.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snack Pack Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snack Pack Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                showCustomSnackBar(
                  context,
                  'Success! Everything went well.',
                  SnackBarType.success,
                );
              },
              child: const Text('Show Success'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                showCustomSnackBar(
                  context,
                  'Error! Something went wrong.',
                  SnackBarType.failure,
                );
              },
              child: const Text('Show Failure'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                showCustomSnackBar(
                  context,
                  'Warning! Please be careful.',
                  SnackBarType.warning,
                );
              },
              child: const Text('Show Warning'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                showCustomSnackBar(
                  context,
                  'Info: This is some useful information.',
                  SnackBarType.info,
                );
              },
              child: const Text('Show Info'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## API Reference

### `showCustomSnackBar`

Displays a custom animated snack bar at the top of the screen.

**Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `context` | `BuildContext` | Yes | - | The build context used to access the overlay |
| `message` | `String` | Yes | - | The message text to display |
| `type` | `SnackBarType` | Yes | - | The type of snack bar (success, failure, warning, or info) |
| `duration` | `Duration` | No | `Duration(seconds: 3)` | How long the snack bar stays visible |
| `config` | `SnackPackConfig` | No | `SnackPackConfig.defaults` | Controls responsive behavior and margins |

### `SnackBarType`

An enum with four values:

| Type | Color | Icon | Use Case |
|------|-------|------|----------|
| `SnackBarType.success` | Green | ✓ Check Circle | Successful operations, confirmations |
| `SnackBarType.failure` | Red | ✕ Error | Errors, failed operations |
| `SnackBarType.warning` | Orange | ⚠ Warning | Warnings, caution messages |
| `SnackBarType.info` | Blue | ℹ Info | Informational messages, tips |

### `SnackPackConfig`

Configuration class for customizing the snack bar's responsive behavior and positioning.

**Properties:**

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `largeBreakpoint` | `double` | `1024` | Screen width (in logical pixels) at or above which the snack bar appears at top-right |
| `maxWidthOnLarge` | `double` | `420` | Maximum width of the snack bar on large screens |
| `margin` | `EdgeInsets` | `EdgeInsets.symmetric(horizontal: 16, vertical: 16)` | Outer padding from screen edges |

**Example:**

```dart
showCustomSnackBar(
  context,
  'Custom configuration',
  SnackBarType.info,
  config: const SnackPackConfig(
    largeBreakpoint: 1200,    // Tablets and desktops
    maxWidthOnLarge: 500,     // Wider on large screens
    margin: EdgeInsets.all(24), // More spacing
  ),
);
```

## Behavior

- **Auto-Dismiss**: Snack bars automatically dismiss after the specified duration
- **Manual Dismiss**: Users can swipe up to manually dismiss
- **Queue Management**: If a new snack bar is shown while one is visible, the old one is immediately removed
- **Animation**: 250ms slide-in and slide-out animations with ease-out curve
- **Responsive**: On large screens (≥1024px), snack bars appear top-right with constrained max width
- **Performance**: Uses Flutter's overlay system for optimal rendering without rebuilding your widget tree

## Platform Support

| Platform | Supported |
|----------|-----------|
| Android | ✅ |
| iOS | ✅ |
| Web | ✅ |
| macOS | ✅ |
| Windows | ✅ |
| Linux | ✅ |

## Screenshots

Below are example screenshots of Snack Pack in action. On large screens, the snack appears at the top-right with a constrained max width.

| Phone (portrait) | Desktop/Web (large screen) |
|---|---|
| ![Phone screenshot](example/screenshots/phone.png) | ![Desktop screenshot](example/screenshots/desktop.png) |

If the images are not visible yet, generate them with the steps in `example/screenshots/README.md`.

## Advanced Usage

### Real-World Examples

**Form Validation:**
```dart
void submitForm() {
  if (!validateEmail(email)) {
    showCustomSnackBar(
      context,
      'Please enter a valid email address',
      SnackBarType.warning,
    );
    return;
  }

  // Process form...
  showCustomSnackBar(
    context,
    'Form submitted successfully!',
    SnackBarType.success,
  );
}
```

**Network Operations:**
```dart
Future<void> fetchData() async {
  try {
    final data = await api.getData();
    showCustomSnackBar(
      context,
      'Data loaded successfully',
      SnackBarType.success,
      duration: const Duration(seconds: 2),
    );
  } catch (e) {
    showCustomSnackBar(
      context,
      'Failed to load data: ${e.toString()}',
      SnackBarType.failure,
      duration: const Duration(seconds: 5),
    );
  }
}
```

**User Actions:**
```dart
void deleteItem(String itemName) {
  // Delete the item...
  showCustomSnackBar(
    context,
    '$itemName has been deleted',
    SnackBarType.info,
  );
}
```

## FAQ

**Q: Can I show multiple snack bars at once?**
A: No, Snack Pack uses smart queue management to ensure only one snack bar is visible at a time. This prevents overlapping notifications and provides a better user experience. When a new snack bar is shown, the previous one is automatically dismissed.

**Q: How do I customize the colors or icons?**
A: Currently, Snack Pack provides four predefined types with their own colors and icons. For custom designs, you can fork the package or submit a feature request for extended customization options.

**Q: Can I position the snack bar at the bottom?**
A: Snack Pack is specifically designed for top-aligned notifications. For bottom notifications, consider using Flutter's built-in `SnackBar` widget.

**Q: Does it work with dark mode?**
A: Yes! Snack Pack's colors are designed to work well in both light and dark themes. The white text provides good contrast against all background colors.

**Q: Is it compatible with Navigator 2.0 and GoRouter?**
A: Yes, as long as you have access to a valid `BuildContext` with an `Overlay`, Snack Pack will work with any routing solution.

**Q: Can I prevent users from dismissing the snack bar?**
A: Currently, users can always swipe to dismiss. The snack bar will also auto-dismiss after the specified duration. This behavior ensures users are never blocked by persistent notifications.

## Performance

Snack Pack is designed to be lightweight and performant:

- **Zero rebuilds**: Uses Flutter's overlay system, so showing a snack bar doesn't trigger rebuilds in your widget tree
- **Efficient animations**: Hardware-accelerated animations using `AnimationController`
- **Smart disposal**: Automatically cleans up resources when dismissed
- **Minimal footprint**: Only ~270 lines of code with no external dependencies

## Troubleshooting

**Snack bar not appearing:**
- Ensure you're passing a valid `BuildContext` that has access to an `Overlay`
- Check that your widget is wrapped in a `MaterialApp` or has an overlay ancestor
- Verify you're not calling it before the first frame is rendered

**Snack bar appearing behind other widgets:**
- This shouldn't happen as Snack Pack uses the overlay system which renders on top
- If you have custom overlays, ensure they're not blocking Snack Pack's overlay

**Animation stuttering:**
- This may indicate performance issues in your app
- Snack Pack uses standard Flutter animations that should be smooth on all platforms

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests: `flutter test`
5. Format code: `dart format .`
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

All pull requests are automatically tested via GitHub Actions.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Dhiraj Nikam**

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes.

## Support

If you encounter any issues or have questions, please file an issue on the [GitHub issue tracker](https://github.com/dhirajnikam/snack_pack/issues).
