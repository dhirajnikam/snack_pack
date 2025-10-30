# Publishing Guide for Snack Pack

This document provides step-by-step instructions for testing and publishing the Snack Pack package to pub.dev.

## 🤖 Automatic Publishing (Recommended)

This repository is configured with **GitHub Actions** for automatic publishing to pub.dev!

When you push to `main` with "release" in the commit message or push a version tag, the package is automatically:
- ✓ Formatted and analyzed
- ✓ Tested
- ✓ Published to pub.dev

See [`.github/PUBLISHING.md`](.github/PUBLISHING.md) for setup instructions.

**Quick publish:**
```bash
# Update version and changelog, then:
git add .
git commit -m "release: version 1.0.1"
git push origin main
```

---

## Manual Publishing

If you prefer to publish manually, follow this guide:

## Pre-Publishing Checklist

Before publishing, ensure you've completed all of these steps:

### 1. Code Quality

```bash
# Format all Dart code
dart format .

# Run static analysis
flutter analyze

# Ensure no errors or warnings
```

### 2. Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Verify all tests pass
```

### 3. Example App

```bash
# Navigate to example directory
cd example

# Get dependencies
flutter pub get

# Run on different platforms
flutter run -d android
flutter run -d ios
flutter run -d chrome
flutter run -d macos
flutter run -d windows
flutter run -d linux

# Test all functionality:
# - All four snack bar types
# - Different durations
# - Swipe to dismiss
# - Auto-dismiss
# - Queue management
```

### 4. Documentation

- [ ] README.md is complete and up-to-date
- [ ] CHANGELOG.md is updated with latest version
- [ ] All public APIs have dartdoc comments
- [ ] Code examples are working and clear
- [ ] LICENSE file is present

### 5. Package Metadata

Verify `pubspec.yaml` contains:
- [ ] Correct package name
- [ ] Version number (following semantic versioning)
- [ ] Description (60-180 characters)
- [ ] Homepage URL
- [ ] Repository URL
- [ ] Issue tracker URL
- [ ] Correct SDK constraints

### 6. Files to Include

Required files:
- [x] `lib/snack_pack.dart` (main library file)
- [x] `lib/src/snack_pack.dart` (implementation)
- [x] `pubspec.yaml`
- [x] `README.md`
- [x] `CHANGELOG.md`
- [x] `LICENSE`

Optional but recommended:
- [x] `example/` directory with working example
- [x] `test/` directory with tests
- [x] `analysis_options.yaml`
- [x] `.gitignore`
- [x] `CONTRIBUTING.md`

## Dry Run

Before actually publishing, perform a dry run to check for any issues:

```bash
# Ensure you're in the package root directory
cd /path/to/snack_pack

# Run dry-run to see what would be published
flutter pub publish --dry-run
```

Review the output carefully:

1. **Package validation**: Ensure all validations pass
2. **Files to be published**: Verify the list of files
3. **Package score**: Check for any warnings or suggestions
4. **Size**: Ensure package size is reasonable

### Common Issues and Fixes

#### Missing Description
```yaml
# pubspec.yaml
description: Your package description here (60-180 characters)
```

#### Version Constraint Issues
```yaml
# pubspec.yaml
environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.0.0'
```

#### Missing Homepage/Repository
```yaml
# pubspec.yaml
homepage: https://github.com/username/snack_pack
repository: https://github.com/username/snack_pack
```

#### Documentation Issues
- Ensure all public APIs have `///` doc comments
- Add code examples to main APIs
- Update README with comprehensive usage guide

## Publishing to pub.dev

### First Time Setup

1. **Create pub.dev Account**
   - Go to https://pub.dev
   - Sign in with Google account
   - Verify your email

2. **Configure Credentials**
   ```bash
   # This will open a browser for authentication
   flutter pub publish --dry-run
   ```

### Publishing Process

1. **Final Version Check**
   ```bash
   # Update version in pubspec.yaml
   version: 1.0.0

   # Update CHANGELOG.md with release notes
   ```

2. **Commit Changes**
   ```bash
   git add .
   git commit -m "Release version 1.0.0"
   git tag v1.0.0
   git push origin main --tags
   ```

3. **Publish**
   ```bash
   # Navigate to package root
   cd /path/to/snack_pack

   # Publish to pub.dev
   flutter pub publish
   ```

4. **Verify Publishing**
   - Confirm the prompt to publish
   - Wait for publishing to complete
   - Check https://pub.dev/packages/snack_pack
   - Verify package appears correctly
   - Check pub.dev score and address any issues

## Post-Publishing

### 1. Monitor Package Health

- Check pub.dev score regularly
- Address any warnings or suggestions
- Monitor GitHub issues for bug reports

### 2. Announce Release

- Create GitHub release with changelog
- Share on social media (if applicable)
- Update any related documentation

### 3. Prepare for Next Version

- Create new development branch
- Update version to next development version (e.g., 1.1.0-dev)
- Add "Unreleased" section to CHANGELOG.md

## Version Numbering

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.0.0): Breaking changes
- **MINOR** (0.1.0): New features, backward compatible
- **PATCH** (0.0.1): Bug fixes, backward compatible

Examples:
- `1.0.0` - First stable release
- `1.1.0` - Added new feature
- `1.1.1` - Fixed bug in 1.1.0
- `2.0.0` - Breaking API change

## Troubleshooting

### "Package is too large"
- Review files being published
- Add unnecessary files to `.pubignore`
- Remove large assets or examples

### "Documentation incomplete"
- Add dartdoc comments to all public APIs
- Include code examples
- Update README

### "Analysis errors"
- Run `flutter analyze`
- Fix all errors and warnings
- Ensure `analysis_options.yaml` is properly configured

### "Test failures"
- Run `flutter test`
- Fix failing tests
- Ensure all tests pass before publishing

## Need Help?

- [pub.dev Publishing Guide](https://dart.dev/tools/pub/publishing)
- [Package Layout Conventions](https://dart.dev/tools/pub/package-layout)
- [Verified Publishers](https://dart.dev/tools/pub/verified-publishers)

## Checklist for Version 1.0.0

- [ ] All code is formatted
- [ ] All tests pass
- [ ] Example app runs on all platforms
- [ ] Documentation is complete
- [ ] CHANGELOG is updated
- [ ] Version is set to 1.0.0
- [ ] Dry run completes successfully
- [ ] Changes are committed and tagged
- [ ] Package is published
- [ ] GitHub release is created
