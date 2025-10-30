Screenshots
===========

This folder stores example screenshots referenced by the root `README.md`:

- `phone.png` — mobile (Android/iOS) portrait
- `desktop.png` — desktop/web large screen

How to capture
--------------

Android/iOS
- Start a simulator/emulator or connect a device
- From repo root:
  - `cd example`
  - Run the example: `flutter run -d <device_id>` and trigger a snack
  - Capture: `flutter screenshot -o screenshots/phone.png`

Web (Chrome)
- `cd example`
- `flutter run -d chrome`
- Resize the browser ≥1024px width, trigger a snack
- Use the browser devtools (Ctrl+Shift+I) — device toolbar — capture screenshot, or your OS screenshot tool, and save to `screenshots/desktop.png`

Windows/macOS/Linux desktop
- `cd example`
- `flutter run -d windows` (or `macos` / `linux`)
- Trigger a snack on a large window; use OS screenshot tool and save to `screenshots/desktop.png`

Tip: ensure the snack is visible when taking the shot (e.g., trigger it immediately before capturing).


