#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/exclusions.sh"
source "$(dirname "$0")/../../../scripts/project_utils.sh"

PROJECT_ROOT=$(find_project_root)
cd "$PROJECT_ROOT" || { echo "Error: could not cd to $PROJECT_ROOT." >&2; exit 1; }

if ! command -v lcov &>/dev/null; then
  echo "Warning: lcov not found — skipping coverage report generation." >&2
  exit 0
fi

lcov --remove coverage/lcov.info \
     --output-file coverage/lcov.info \
     "${EXCLUDE[@]}" \
     >/dev/null 2>&1 || true

if command -v genhtml &>/dev/null; then
  genhtml coverage/lcov.info -o coverage/html >/dev/null 2>&1 || true
  echo "HTML report available at coverage/html/index.html."
fi

echo "Coverage report generated at coverage/lcov.info."
