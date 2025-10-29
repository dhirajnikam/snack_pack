# Contributing to Snack Pack

Thank you for your interest in contributing to Snack Pack! This document provides guidelines for contributing to the project.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/snack_pack.git`
3. Create a new branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test your changes
6. Commit your changes: `git commit -m "Add some feature"`
7. Push to the branch: `git push origin feature/your-feature-name`
8. Submit a pull request

## Development Setup

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)

### Installation

```bash
# Get dependencies
flutter pub get

# Run the example app
cd example
flutter pub get
flutter run
```

## Code Style

This project follows the official [Dart style guide](https://dart.dev/guides/language/effective-dart/style) and uses `flutter_lints` for code analysis.

### Running the Analyzer

```bash
flutter analyze
```

### Formatting Code

```bash
dart format .
```

## Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Writing Tests

- Write tests for all new features
- Ensure existing tests pass before submitting a PR
- Aim for high test coverage
- Test files should be in the `test/` directory
- Name test files with `_test.dart` suffix

## Pull Request Process

1. Update the README.md with details of changes if applicable
2. Update the CHANGELOG.md following the [Keep a Changelog](https://keepachangelog.com/) format
3. Ensure all tests pass
4. Ensure code passes `flutter analyze` without warnings
5. Format your code with `dart format`
6. Update documentation if you're changing functionality

## Commit Message Guidelines

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests liberally after the first line

Examples:
```
Add swipe-down dismiss functionality

- Implement downward swipe detection
- Add animation for downward dismissal
- Update tests to cover new behavior

Fixes #123
```

## Code Review Process

- All submissions require review before being merged
- Maintainers will review your PR and may request changes
- Once approved, a maintainer will merge your PR

## Feature Requests and Bug Reports

### Bug Reports

When filing a bug report, please include:

1. A clear and descriptive title
2. Steps to reproduce the issue
3. Expected behavior
4. Actual behavior
5. Flutter version and platform (iOS, Android, Web, etc.)
6. Screenshots if applicable
7. Any relevant error messages or logs

### Feature Requests

When requesting a feature, please include:

1. A clear and descriptive title
2. Detailed description of the proposed feature
3. Use cases and examples
4. Why this feature would be useful
5. Any implementation ideas (optional)

## Documentation

- Document all public APIs with dartdoc comments
- Include code examples in documentation
- Update README.md for significant changes
- Keep documentation up to date with code changes

## Questions?

Feel free to open an issue with your question, and we'll do our best to help!

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
