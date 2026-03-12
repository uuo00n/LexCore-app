#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

FILES=()
while IFS= read -r file; do
  FILES+=("$file")
done < <(
  rg --files lib \
    -g '*.dart' \
    -g '!theme.dart' \
    -g '!**/*.g.dart' \
    -g '!**/*.freezed.dart'
)

if [ "${#FILES[@]}" -eq 0 ]; then
  echo "No Dart source files found under lib/."
  exit 0
fi

PATTERN='AppColors\.|AppTheme\.|\bColors\.|\bColor\('
set +e
VIOLATIONS="$(rg -n --color=never "$PATTERN" "${FILES[@]}")"
STATUS=$?
set -e

if [ "$STATUS" -eq 0 ] && [ -n "$VIOLATIONS" ]; then
  echo "Theme usage violations found:"
  echo
  echo "$VIOLATIONS"
  echo
  echo "Use Theme.of(context).colorScheme or context.tokens instead."
  exit 1
fi

echo "Theme usage check passed."
