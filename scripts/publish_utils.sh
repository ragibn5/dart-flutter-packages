#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Validate a package path has a pubspec.yaml
validate_package_path() {
  local pkg_path="$1"
  local full_path="$REPO_ROOT/$pkg_path"

  if [[ ! -d "$full_path" ]]; then
    echo "Error: Directory '$pkg_path' not found."
    return 1
  fi
  if [[ ! -f "$full_path/pubspec.yaml" ]]; then
    echo "Error: No pubspec.yaml found in '$pkg_path'."
    return 1
  fi
  return 0
}

get_package_name() {
  local pkg_path="$1"
  grep "^name:" "$REPO_ROOT/$pkg_path/pubspec.yaml" 2>/dev/null | sed 's/name: *//' | tr -d '"' | tr -d "'" | tr -d '[:space:]'
}

get_package_version() {
  local pkg_path="$1"
  grep "^version:" "$REPO_ROOT/$pkg_path/pubspec.yaml" 2>/dev/null | sed 's/version: *//' | tr -d '"' | tr -d "'" | tr -d '[:space:]'
}

ensure_clean_working_tree() {
  if ! git -C "$REPO_ROOT" diff --quiet HEAD 2>/dev/null; then
    echo "Error: Working tree has uncommitted changes."
    return 1
  fi
  if ! git -C "$REPO_ROOT" diff --cached --quiet 2>/dev/null; then
    echo "Error: Staged changes exist."
    return 1
  fi
  return 0
}

dry_run_publish() {
  local pkg_path="$1"
  echo ""
  echo "=== Dry-run publish ==="
  (cd "$REPO_ROOT/$pkg_path" && dart pub publish --dry-run)
  local result=$?
  echo "=== Dry-run complete ==="
  echo ""
  return $result
}

do_publish() {
  local pkg_path="$1"
  echo ""
  echo "=== Publishing ==="
  (cd "$REPO_ROOT/$pkg_path" && dart pub publish)
  local result=$?
  if [[ $result -eq 0 ]]; then
    echo "Successfully published!"
  else
    echo "Error: Publishing failed."
  fi
  return $result
}
