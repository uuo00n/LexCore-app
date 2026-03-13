# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LexCore (`lexcore`) is an intelligent legal service platform built with Flutter. It provides legal consultation, document generation, case analysis, and law retrieval via a multi-agent AI backend.

## Build & Development Commands

```bash
flutter pub get                          # Install dependencies
flutter run -d <device>                  # Run (chrome, ios, emulator id)
flutter analyze                          # Static analysis (flutter_lints)
flutter test                             # Run all tests
flutter test test/path/to_test.dart      # Run a single test file
dart format lib test                     # Format code
flutter pub run build_runner build --delete-conflicting-outputs  # Generate freezed/JSON code
```

**Pre-commit checks** (must pass before PR):
```bash
flutter analyze && flutter test && ./tool/check_theme_usage.sh
```

`tool/check_theme_usage.sh` scans all Dart files under `lib/` (except `theme.dart` and generated files) for forbidden color patterns: `AppColors.`, `AppTheme.`, `Colors.*`, `Color(...)`.

## Architecture

**Feature-first Clean Architecture** with four layers per feature:

```
lib/features/<feature>/
├── application/       # Riverpod providers and state notifiers
├── data/repositories/ # Data sources and repository implementations
├── domain/entities/   # Business entities
└── presentation/      # Pages (_page.dart) and widgets
```

**Core layers:**
- `lib/app/` — App bootstrap (`app.dart`), GoRouter config, DI (Riverpod providers), theme tokens, motion/animation system, adaptive layout utilities, navigation shell
- `lib/core/` — Cross-cutting: constants, network (Dio), storage, error handling, extensions
- `lib/shared/` — Reusable components (`AppPrimaryButton`, `AppInputField`, `AppSurfaceCard`, `AppListTileItem`), layout widgets (`AppPageScaffold`, `AppBottomNavigation`, `AppMobileCanvas`), shared models (`legal_models.dart`), mock services
- `lib/theme.dart` — Single source of truth for Material 3 color schemes (light/dark/contrast variants)

**Key technology choices:**
- **State management:** Riverpod (`flutter_riverpod`)
- **Routing:** GoRouter with `StatefulShellRoute` for bottom nav (4 branches: home, search, history, profile). Page transitions via `AppPageTransitions` with kinds: standard, detail, modal, none
- **HTTP:** Dio
- **Fonts:** Google Fonts (Public Sans)

## Theme & Color Rules (Critical)

All colors must come from the theme system. This is enforced by `check_theme_usage.sh`.

- **Use:** `Theme.of(context).colorScheme` or `context.tokens` (via `AppTokensExtension`)
- **Never use in lib/ (except theme.dart):** `AppColors`, `AppTheme`, `Colors.*`, or `Color(...)` literals
- Extended tokens: `context.tokens.success`, `.warning`, `.danger`, `.info`, `.chatAiBubble`, `.chatUserBubble`
- When generating UI with MCP tools, include this constraint in prompts

## Responsive Design

Four breakpoints defined in `AppBreakpoints`:
- Compact: < 600px (mobile, bottom nav, single column)
- Medium: 600–1024px (tablet, sidebar nav)
- Expanded: 1024–1440px (desktop, split layouts)
- Ultra: >= 1440px (large desktop)

Access via context extensions: `context.viewportSize`, `context.isCompactViewport`, etc. Use `AppAdaptiveFrame` for content width constraints and `AppAdaptiveSplitView` for two-column layouts.

## Animation System

Defined in `lib/app/motion/`:
- `AppMotion` — Timing constants (page: 280ms, component: 180ms, stagger step: 40ms)
- `AppFadeSlideIn` — Standard entrance animation (fade + vertical slide)
- `AppStagger` / `AppStaggeredListEntrance` — Staggered list animations
- `AppAnimatedSwap` — State transition animations

## Conventions

- **File naming:** `snake_case.dart`; pages end with `_page.dart`; repos in `data/repositories/`
- **Providers:** End with `Provider` (e.g. `analysisReportProvider`)
- **Imports:** Absolute `package:lexcore/...` paths; group by dart, flutter, packages, then internal
- **Mock data:** Keep in repository/mock layers (`shared/services/mock/`), not in widgets
- **Commits:** Conventional Commit style — `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`
- **Tests:** `flutter_test` framework, files end with `_test.dart`, mirror lib structure in `test/`
