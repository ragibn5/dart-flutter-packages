#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=./prompt_utils.sh
source "$SCRIPT_DIR/prompt_utils.sh"
# shellcheck source=./publish_utils.sh
source "$SCRIPT_DIR/publish_utils.sh"

usage() {
  echo ""
  echo "Usage: $0 [options] <package-path>"
  echo ""
  echo "  <package-path>   Relative path from repo root to package directory"
  echo ""
  echo "Options:"
  echo "  --dry-run   Only run dry-run checks, don't actually publish"
  echo "  -h, --help  Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0 dlogger              # Publish dlogger"
  echo "  $0 packages/core_utils  # Publish a nested package"
  echo "  $0 --dry-run dlogger    # Dry-run only"
  echo ""
  exit 0
}

# --- Parse args ---
DRY_RUN=false
PACKAGE_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help) usage ;;
    -*)        echo "Unknown option: $1"; usage ;;
    *)         PACKAGE_PATH="$1"; shift ;;
  esac
done

if [[ -z "$PACKAGE_PATH" ]]; then
  echo "Error: No package path specified."
  usage
fi

if ! validate_package_path "$PACKAGE_PATH"; then
  exit 1
fi

# --- Pre-flight checks ---
echo ""
echo "=== Pre-flight checks ==="

echo "Checking working tree..."
ensure_clean_working_tree || exit 1
echo "  OK: clean."

PKG_NAME=$(get_package_name "$PACKAGE_PATH")
PKG_VERSION=$(get_package_version "$PACKAGE_PATH")
echo "  Package: $PKG_NAME"
echo "  Version: $PKG_VERSION"
echo ""

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
