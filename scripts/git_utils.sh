#!/usr/bin/env bash

set -euo pipefail

COMMAND="${1:?Usage: $0 <command> [args...]}"
shift

case "$COMMAND" in
  detect_folder_changes)
    FOLDER="${1:?Usage: $0 detect_folder_changes <folder>}"

    if [ "${GITHUB_EVENT_NAME:-}" = "pull_request" ]; then
      BASE="origin/${GITHUB_BASE_REF}"
    else
      BASE="HEAD~1"
    fi

    if git diff --name-only "$BASE"...HEAD | grep -q "^${FOLDER}/"; then
      echo "Changes detected in ${FOLDER}/"
      exit 0
    else
      echo "No changes in ${FOLDER}/ — skipping."
      exit 1
    fi
    ;;
  *)
    echo "Unknown command: $COMMAND"
    exit 1
    ;;
esac
