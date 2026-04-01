#!/bin/bash

# Runs tests for all packages in this repository.
# Packages with .fvmrc use FVM to resolve the correct Flutter/Dart SDK.

set -o pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Flutter packages (use `flutter test`)
FLUTTER_PACKAGES=(
  app_template
  color_utils
  menu
  radio_group
  selection_group
)

# Dart-only packages (use `dart test`)
DART_PACKAGES=(
  analysis_plugin_test_helper
  analysis_server_core
  clean_arch_lint
  collection_extensions
  datetime_utils
  dlogger
  functions
  generator_core
  json_parser
  json_parser/json_parser_analyzer
  json_parser/json_parser_annotations
  json_parser/json_parser_generator
  net_kit
  parser
  string_extensions
)

PASSED=()
FAILED=()

run_tests() {
  local pkg="$1"
  local cmd="$2"
  local pkg_dir="$ROOT_DIR/$pkg"

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Testing: $pkg"
  echo "Command: $cmd"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  (cd "$pkg_dir" && eval "$cmd")

  if [ $? -eq 0 ]; then
    PASSED+=("$pkg")
  else
    FAILED+=("$pkg")
  fi
}

for pkg in "${FLUTTER_PACKAGES[@]}"; do
  pkg_dir="$ROOT_DIR/$pkg"
  if [ -f "$pkg_dir/.fvmrc" ]; then
    run_tests "$pkg" "fvm flutter test"
  else
    run_tests "$pkg" "flutter test"
  fi
done

for pkg in "${DART_PACKAGES[@]}"; do
  pkg_dir="$ROOT_DIR/$pkg"
  if [ -f "$pkg_dir/.fvmrc" ]; then
    run_tests "$pkg" "fvm dart test"
  else
    run_tests "$pkg" "dart test"
  fi
done

echo ""
echo "════════════════════════════════════════"
echo "Results: ${#PASSED[@]} passed, ${#FAILED[@]} failed"
echo "════════════════════════════════════════"

if [ ${#FAILED[@]} -gt 0 ]; then
  echo "Failed packages:"
  for pkg in "${FAILED[@]}"; do
    echo "✗ $pkg"
  done
  echo ""
  exit 1
else
  echo "All packages passed."
  echo ""
fi