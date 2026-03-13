# Repository Guidelines

## Project Structure & Module Organization
This repository is a Flutter app (`lexcore`) using a feature-first layered architecture.

- `lib/app`: app bootstrap, routing, adaptive layout, motion, theme tokens.
- `lib/core`: constants, network/storage utilities, error handling, context extensions.
- `lib/shared`: reusable widgets/components, shared models, mock services.
- `lib/features/<feature>`: split into `presentation`, `application`, `data`, `domain`.
- `test/`: unit and widget tests, generally mirroring app structure.
- `assets/`: icons/images; platform runners are under `android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/`.

Example feature path: `lib/features/analysis/presentation/pages/analysis_result_page.dart`.

## Build, Test, and Development Commands
Run from repo root:

- `flutter pub get`: install dependencies.
- `flutter run -d <device>`: run locally (`chrome`, emulator id, etc.).
- `flutter analyze`: static analysis and lint checks.
- `flutter test`: run all tests.
- `dart format lib test`: format source code.
- `flutter pub run build_runner build --delete-conflicting-outputs`: regenerate code when using builders.
- `./tool/check_theme_usage.sh`: enforce theme/color usage rules.

## Coding Style & Naming Conventions
- Follow `flutter_lints`; use 2-space indentation.
- File names: `snake_case.dart`; classes/types: `UpperCamelCase`; members: `lowerCamelCase`.
- Riverpod providers should end with `Provider`.
- Page files should end with `_page.dart`.
- Keep mock/sample data in repository/mock layers, not UI widgets.
- In `lib/`, use only `Theme.of(context).colorScheme` and `context.tokens` for colors.
- Do not use `AppColors`, `AppTheme`, `Colors.*`, or `Color(...)` in `lib/` (except `lib/theme.dart`).

## Testing Guidelines
- Framework: `flutter_test`.
- Test files must end with `_test.dart`.
- Add tests for new business logic (controllers/repositories) and key widget flows.
- Before opening a PR, run: `flutter analyze && flutter test && ./tool/check_theme_usage.sh`.

## Commit & Pull Request Guidelines
- Use Conventional Commits, e.g. `feat(auth): 优化登录流程`, `refactor(ui): 统一列表样式`.
- Keep commits focused and scoped to one concern.
- PRs should include:
  - concise change summary,
  - affected modules/routes,
  - screenshots for UI changes (mobile-first),
  - verification results (`analyze`, `test`, theme check),
  - linked issue/task if available.
