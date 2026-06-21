#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../../../scripts/project_utils.sh"
source "$(dirname "$0")/../../../scripts/flutter_utils.sh"

PROJECT_ROOT=$(find_project_root)
cd "$PROJECT_ROOT" || { echo "Error: could not cd to $PROJECT_ROOT" >&2; exit 1; }

FLUTTER=$(get_flutter_cmd)
$FLUTTER test --no-test-assets --coverage --coverage-path coverage/lcov.info

echo "Coverage data generated at coverage/lcov.info"
