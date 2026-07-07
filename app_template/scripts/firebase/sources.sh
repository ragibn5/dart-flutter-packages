#!/bin/bash

FIREBASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIREBASE_SHARED="$(cd "$FIREBASE_DIR/../../../scripts" && pwd)"

source "$FIREBASE_SHARED/prompt_utils.sh"

unset FIREBASE_DIR FIREBASE_SHARED
