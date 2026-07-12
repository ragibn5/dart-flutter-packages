#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=./prompt_utils.sh
source "$SCRIPT_DIR/prompt_utils.sh"
# shellcheck source=./publish_utils.sh
source "$SCRIPT_DIR/publish_utils.sh"

usage() {
  echo ""
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  --dry-run   Only run dry-run checks, don't actually publish"
  echo "  -h, --help  Show this help message"
  echo ""
  echo "Must be run from a release branch (release/<package-path>-<version>)."
  echo ""
  echo "Examples:"
  echo "  $0              # Publish package from current branch"
  echo "  $0 --dry-run    # Dry-run only"
  echo ""
  exit 0
}

# --- Parse args ---
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help) usage ;;
    -*)        echo "Unknown option: $1"; usage ;;
    *)         echo "Unknown argument: $1"; usage ;;
  esac
done

# --- Early checks ---
BRANCH_INFO=$(run_early_checks) || exit 1

PACKAGE_PATH=$(echo "$BRANCH_INFO" | cut -d' ' -f1)
BRANCH_VER=$(echo "$BRANCH_INFO" | cut -d' ' -f2)
CURRENT_BRANCH=$(git -C "$REPO_ROOT" branch --show-current)

# --- Pre-flight checks ---
echo ""
echo "PRE-FLIGHT CHECKS"

WARNINGS=0

PKG_NAME=$(get_package_name "$PACKAGE_PATH")
PKG_VERSION=$(get_package_version "$PACKAGE_PATH")
echo "  Package: $PKG_NAME"
echo "  Version: $PKG_VERSION"
echo "  Branch:  $CURRENT_BRANCH"

if [[ "$BRANCH_VER" != "$PKG_VERSION" ]]; then
  echo ""
  echo "Error: Version mismatch — branch says $BRANCH_VER, pubspec says $PKG_VERSION."
  exit 1
fi

if ! check_clean_working_tree; then
  echo "  WARNING: You have uncommitted changes."
  WARNINGS=$((WARNINGS + 1))
fi

echo ""

if [[ $WARNINGS -gt 0 ]]; then
  if ! confirm_yes_no "Continue despite warnings?"; then
    echo "Cancelled."
    exit 0
  fi
fi

# --- Dry-run ---
if dry_run_publish "$PACKAGE_PATH"; then
  echo "Dry-run passed."
else
  echo "Dry-run failed. Fix issues before publishing."
  exit 1
fi

# --- Actual publish ---
if [[ "$DRY_RUN" == true ]]; then
  echo ""
  echo "Dry-run complete. Skipping actual publish."
  exit 0
fi

if ! confirm_yes_no "Publish $PKG_NAME@$PKG_VERSION?"; then
  echo "Cancelled."
  exit 0
fi

do_publish "$PACKAGE_PATH" || exit 1
