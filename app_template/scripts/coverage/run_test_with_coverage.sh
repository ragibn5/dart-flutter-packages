#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/sources.sh"

PROJECT_ROOT=$(find_project_root)
cd "$PROJECT_ROOT" || { echo "Error: could not cd to $PROJECT_ROOT." >&2; exit 1; }

FLUTTER=$(get_flutter_cmd)
$FLUTTER test --no-test-assets --coverage --coverage-path coverage/lcov.info

echo "Coverage data generated at coverage/lcov.info."
