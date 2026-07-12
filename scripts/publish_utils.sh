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

# Parse a release branch name. Returns "package_path version" or empty string.
# Expected format: release/<package-path>-<version>
# Package path can contain slashes (e.g., packages/core_utils)
parse_release_branch() {
  local branch="$1"
  if [[ ! "$branch" =~ ^release/ ]]; then
    return 1
  fi

  local rest="${branch#release/}"
  # Match: everything up to last -<major>.<minor>.<patch>
  if [[ "$rest" =~ ^(.+)-([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
    echo "${BASH_REMATCH[1]} ${BASH_REMATCH[2]}"
    return 0
  fi
  return 1
}

# Check if a package directory exists in the monorepo
package_dir_exists() {
  local pkg_name="$1"
  [[ -d "$REPO_ROOT/$pkg_name" ]]
}

# Check if working tree has uncommitted changes. Returns 0 if clean.
check_clean_working_tree() {
  if ! git -C "$REPO_ROOT" diff --quiet HEAD 2>/dev/null; then
    return 1
  fi
  return 0
}

# --- Early check functions ---
# Each returns 0 on success, 1 on failure with an error message.
# Add new checks here as needed.

check_release_branch() {
  local current_branch
  current_branch=$(git -C "$REPO_ROOT" branch --show-current 2>/dev/null || true)

  if [[ -z "$current_branch" ]]; then
    echo "Error: Detached HEAD. Checkout a release branch first."
    return 1
  fi

  if [[ ! "$current_branch" =~ ^release/ ]]; then
    echo "Error: Not on a release branch (current: $current_branch)."
    return 1
  fi

  local branch_info
  branch_info=$(parse_release_branch "$current_branch" || true)
  if [[ -z "$branch_info" ]]; then
    echo "Error: Branch name does not match format release/<package-path>-<version>."
    return 1
  fi

  echo "$branch_info"
  return 0
}

check_package_exists() {
  local pkg_name="$1"
  if ! package_dir_exists "$pkg_name"; then
    echo "Error: Package '$pkg_name' not found in monorepo."
    return 1
  fi
  return 0
}

# Run all early checks. Returns parsed branch info on success.
# Usage: branch_info=$(run_early_checks) || exit 1
run_early_checks() {
  local branch_info
  branch_info=$(check_release_branch 2>&1) || {
    echo "$branch_info" >&2
    return 1
  }

  local pkg_name
  pkg_name=$(echo "$branch_info" | cut -d' ' -f1)

  check_package_exists "$pkg_name" >&2 || return 1

  echo "$branch_info"
  return 0
}

dry_run_publish() {
  local pkg_path="$1"
  echo ""
  echo "DRY-RUN PUBLISH"
  (cd "$REPO_ROOT/$pkg_path" && dart pub publish --dry-run)
  local result=$?
  echo "DRY-RUN COMPLETE"
  echo ""
  return $result
}

do_publish() {
  local pkg_path="$1"
  echo ""
  echo "PUBLISHING"
  (cd "$REPO_ROOT/$pkg_path" && dart pub publish)
  local result=$?
  if [[ $result -eq 0 ]]; then
    echo "Successfully published!"
  else
    echo "Error: Publishing failed."
  fi
  return $result
}
