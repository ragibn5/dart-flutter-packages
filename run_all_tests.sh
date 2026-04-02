#!/bin/bash

# Runs tests for all packages in this repository.
# Discovers packages dynamically by finding all pubspec.yaml files recursively.
# Packages with .fvmrc use FVM to resolve the correct Flutter/Dart SDK.

set -o pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

FLUTTER_PKGS=()
DART_PKGS=()
NO_TEST_PKGS=()
PASSED=()
FAILED=()

# ── Helpers ───────────────────────────────────────────────────────────────────

is_flutter_package() {
  grep -q "sdk: flutter" "$1"
}

has_tests() {
  local pkg_dir="$1"
  [ -d "$pkg_dir/test" ] || return 1
  while IFS= read -r file; do
    grep -q '[^[:space:]]' "$file" && return 0
  done < <(find "$pkg_dir/test" -name "*.dart" 2>/dev/null)
  return 1
}

test_cmd_for() {
  local pkg_dir="$1"
  local base_cmd="$2"
  if [ -f "$pkg_dir/.fvmrc" ]; then
    echo "fvm $base_cmd"
  else
    echo "$base_cmd"
  fi
}

# ── Discovery ─────────────────────────────────────────────────────────────────

discover_packages() {
  while IFS= read -r pubspec; do
    local pkg_dir
    pkg_dir="$(dirname "$pubspec")"
    [ "$pkg_dir" = "$ROOT_DIR" ] && continue

    local rel_path="${pkg_dir#"$ROOT_DIR"/}"

    if ! has_tests "$pkg_dir"; then
      NO_TEST_PKGS+=("$rel_path")
    elif is_flutter_package "$pubspec"; then
      FLUTTER_PKGS+=("$pkg_dir")
    else
      DART_PKGS+=("$pkg_dir")
    fi
  done < <(find "$ROOT_DIR" \
    -name "pubspec.yaml" \
    -not -path "*/.dart_tool/*" \
    -not -path "*/build/*" \
    -not -path "*/.pub/*" \
    | sort)
}

# ── Summary ───────────────────────────────────────────────────────────────────

print_summary() {
  echo ""
  echo "════════════════════════════════════════"
  echo "Discovery Summary"
  echo "════════════════════════════════════════"

  echo ""
  echo "Flutter packages (${#FLUTTER_PKGS[@]}):"
  for pkg_dir in "${FLUTTER_PKGS[@]}"; do
    local rel="${pkg_dir#"$ROOT_DIR"/}"
    echo "  • $rel"
  done

  echo ""
  echo "Dart packages (${#DART_PKGS[@]}):"
  for pkg_dir in "${DART_PKGS[@]}"; do
    local rel="${pkg_dir#"$ROOT_DIR"/}"
    echo "  • $rel"
  done

  echo ""
  echo "No tests found (${#NO_TEST_PKGS[@]}):"
  if [ ${#NO_TEST_PKGS[@]} -eq 0 ]; then
    echo "  [Nothing found]"
  else
    for rel in "${NO_TEST_PKGS[@]}"; do
      echo "  • $rel"
    done
  fi
}

# ── Test runner ───────────────────────────────────────────────────────────────

run_tests() {
  local pkg_dir="$1"
  local cmd="$2"
  local rel_path="${pkg_dir#"$ROOT_DIR"/}"

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Testing: $rel_path"
  echo "Command: $cmd"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  if (cd "$pkg_dir" && eval "$cmd"); then
    PASSED+=("$rel_path")
  else
    FAILED+=("$rel_path")
  fi
}

run_all_tests() {
  echo ""
  echo "════════════════════════════════════════"
  echo "Starting tests..."
  echo "════════════════════════════════════════"

  for pkg_dir in "${FLUTTER_PKGS[@]}"; do
    run_tests "$pkg_dir" "$(test_cmd_for "$pkg_dir" "flutter test")"
  done

  for pkg_dir in "${DART_PKGS[@]}"; do
    run_tests "$pkg_dir" "$(test_cmd_for "$pkg_dir" "dart test")"
  done
}

# ── Results ───────────────────────────────────────────────────────────────────

print_results() {
  echo ""
  echo "════════════════════════════════════════"
  echo "Results: ${#PASSED[@]} passed, ${#FAILED[@]} failed"
  echo "════════════════════════════════════════"

  local has_issues=0

  if [ ${#FAILED[@]} -gt 0 ]; then
    echo "Failed packages:"
    for pkg in "${FAILED[@]}"; do
      echo "  ✗ $pkg"
    done
    echo ""
    has_issues=1
  fi

  if [ ${#NO_TEST_PKGS[@]} -gt 0 ]; then
    echo "Skipped packages:"
    for pkg in "${NO_TEST_PKGS[@]}"; do
      echo "  - $pkg  [no tests]"
    done
    echo ""
  fi

  if [ $has_issues -eq 0 ]; then
    echo "All packages passed."
    echo ""
  else
    return 1
  fi
}

# ── Main ──────────────────────────────────────────────────────────────────────

main() {
  discover_packages
  print_summary
  run_all_tests
  print_results
}

main