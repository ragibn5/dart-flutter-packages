#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/utils.sh"
PROJECT_ROOT=$(find_project_root)
cd "$PROJECT_ROOT"

FLUTTER="${FLUTTER:-fvm flutter}"

$FLUTTER test --no-test-assets --coverage --coverage-path coverage/lcov.info

if command -v lcov &>/dev/null; then
  # Define exclusions here
  EXCLUDE=(
    # DI setup
    'lib/di/config/**'
    'lib/di/modules/**'
    'lib/di/di.dart'

    # Generated directories and files
    'lib/generated/**'
    'lib/**/*.g.dart'
    'lib/**/*.gen.dart'
    'lib/**/firebase_options_*.dart'

    # Entry points
    'lib/main_*.dart'

    # Models (data objects)
    'lib/**/models/**'

    # Constants
    'lib/**/constants'

    # UI (widget tests not considered)
    'lib/**/presentation/widgets/**'

    # BLoC boilerplate
    'lib/**/*_event.dart'
    'lib/**/*_state.dart'

    # Feature specifics
    'lib/features/app/infrastructure/config/**'
  )

  lcov --remove coverage/lcov.info \
       --output-file coverage/lcov.info \
       "${EXCLUDE[@]}" \
       2>/dev/null || true

  if command -v genhtml &>/dev/null; then
    genhtml coverage/lcov.info -o coverage/html
    echo "HTML report available at coverage/html/index.html"
  fi
fi

echo "Coverage report generated at coverage/lcov.info"