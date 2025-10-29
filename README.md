# Snack Pack

A beautiful and customizable animated snack bar package for Flutter. Display top-aligned snack bars with smooth animations and swipe-to-dismiss functionality.

## Features

- **Four Built-in Types**: Success, Failure, Warning, and Info with distinct colors and icons
- **Smooth Animations**: Slide-in and slide-out animations with customizable curves
- **Swipe to Dismiss**: Users can swipe up to dismiss the snack bar
- **Auto-Dismiss**: Automatically dismisses after a customizable duration
- **Smart Queue Management**: Only one snack bar visible at a time
- **Safe Area Aware**: Respects device notches and status bars
- **Easy to Use**: Simple API with sensible defaults

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

### `SnackBarType`

An enum with four values:

- `SnackBarType.success` - Green background with check icon
- `SnackBarType.failure` - Red background with error icon
- `SnackBarType.warning` - Orange background with warning icon
- `SnackBarType.info` - Blue background with info icon

## Behavior

- **Auto-Dismiss**: Snack bars automatically dismiss after the specified duration
- **Manual Dismiss**: Users can swipe up to manually dismiss
- **Queue Management**: If a new snack bar is shown while one is visible, the old one is immediately removed
- **Animation**: 250ms slide-in and slide-out animations with ease-out curve

## Platform Support

| Platform | Supported |
|----------|-----------|
| Android | ✅ |
| iOS | ✅ |
| Web | ✅ |
| macOS | ✅ |
| Windows | ✅ |
| Linux | ✅ |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Dhiraj Nikam**

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes.

## Support

If you encounter any issues or have questions, please file an issue on the [GitHub issue tracker](https://github.com/dhirajnikam/snack_pack/issues).
