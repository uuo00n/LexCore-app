#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TARGET_DIR="$ROOT_DIR/lib"
PATTERN='MockLegalRepository|mock_providers|CaseDetailData\.demo\(|shared/services/mock|seedThread'

if rg -n --glob '!**/*.g.dart' "$PATTERN" "$TARGET_DIR"; then
  echo
  echo "发现遗留 mock/demo 引用，请先清理后再构建。"
  exit 1
fi

echo "mock/demo 扫描通过。"
