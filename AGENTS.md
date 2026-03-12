# Repository Guidelines

## Project Structure & Module Organization
This repository is a Flutter app (`lexcore`) with a feature-first layered architecture.

- `lib/app`: app bootstrap (`app.dart`), routing (`app_router.dart`), DI, and theme tokens.
- `lib/core`: cross-cutting utilities (constants, network, storage, errors, extensions).
- `lib/shared`: reusable UI components, shared models, and mock services.
- `lib/features/<feature>`: each feature is split into `presentation`, `application`, `data`, and `domain`.
- `test/`: widget/unit tests.
- `android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/`: platform runners.

Example feature path: `lib/features/analysis/presentation/pages/analysis_result_page.dart`.

## Build, Test, and Development Commands
Use these commands from repository root:

- `flutter pub get`: install dependencies.
- `flutter run -d <device>`: run locally (e.g. `chrome`, `ios`, emulator id).
- `flutter analyze`: static analysis with lint rules.
- `flutter test`: run all tests.
- `dart format lib test`: format source and tests.
- `flutter pub run build_runner build --delete-conflicting-outputs`: generate `freezed`/JSON code.

## Coding Style & Naming Conventions
- Follow `flutter_lints` and keep 2-space indentation.
- File names: `snake_case.dart`; classes/types: `UpperCamelCase`; variables/methods: `lowerCamelCase`.
- Riverpod providers should end with `Provider` (e.g. `analysisReportProvider`).
- Page files should end with `_page.dart`; repositories should live in `data/repositories`.
- Do not scatter mock data in widgets; keep it in repository/mock layers.
- Color source of truth: `lib/theme.dart`.
- In `lib/`, always use `Theme.of(context).colorScheme` and `context.tokens` for colors.
- In `lib/`, do not use `AppColors`, `AppTheme`, `Colors.*`, or direct `Color(...)` literals (except `lib/theme.dart`).

## Testing Guidelines
- Framework: `flutter_test`.
- Test files must end with `_test.dart`.
- Add tests for new business logic (controllers/repositories) and key widget flows.
- Before opening a PR, run: `flutter analyze && flutter test && ./tool/check_theme_usage.sh`.
- No strict coverage gate yet, but new logic should not be merged without tests.

## MCP Theme Prompt
- For MCP-generated or MCP-edited pages, include this constraint in prompt:
  `Use only Theme.of(context).colorScheme and context.tokens for colors. Do not use AppColors, AppTheme, Colors.*, or Color(...).`

## Commit & Pull Request Guidelines
- Follow Conventional Commit style seen in history: `type: message` (example: `feat: 初始化项目并完成首次提交`).
- Recommended types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`.
- Keep commits focused and atomic by module/feature.
- PRs should include:
  - change summary,
  - affected modules/routes,
  - screenshots for UI changes (mobile-first),
  - `flutter analyze` and `flutter test` results,
  - linked issue/task when available.
