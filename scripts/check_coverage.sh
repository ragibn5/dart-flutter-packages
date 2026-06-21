#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/project_utils.sh"
source "$(dirname "$0")/coverage_utils.sh"

lcov_file="${1:-coverage/lcov.info}"
threshold="${2:-100}"

PROJECT_ROOT=$(find_project_root)
cd "$PROJECT_ROOT" || { echo "Error: could not cd to $PROJECT_ROOT." >&2; exit 1; }

pct=$(get_coverage_pct "$lcov_file")
if [[ -n "$pct" ]]; then
  echo "Coverage: ${pct}%."
  if (( $(echo "$pct < $threshold" | bc -l) )); then
    echo "ERROR: Coverage ${pct}% is below required ${threshold}%." >&2
    echo "       Make sure you ran 'make run-tests-with-coverage && make process-coverage-data' first for fresh coverage data." >&2
    exit 1
  fi
  echo "Coverage meets required ${threshold}%."
else
  echo "Error: Could not parse coverage data." >&2
  echo "       Make sure you ran 'make run-tests-with-coverage && make process-coverage-data' first for fresh coverage data." >&2
  exit 1
fi
