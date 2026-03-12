# lexcore

LexCore is an intelligent legal service platform powered by multi-agent collaboration for legal consultation, document generation, case analysis, and law retrieval.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Theme Policy

- The single source of truth for app colors is `lib/theme.dart`.
- Feature pages and shared widgets must read colors from `Theme.of(context).colorScheme` or `context.tokens`.
- Do not use `AppColors`, `AppTheme`, `Colors.*`, or direct `Color(...)` literals in `lib/` (except `lib/theme.dart`).

## Pre-commit Checks

Run these checks before opening a PR:

```bash
flutter analyze
flutter test
./tool/check_theme_usage.sh
```
