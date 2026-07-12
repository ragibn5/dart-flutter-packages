#!/bin/bash

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_SCRIPTS_DIR="$(cd "$SELF_DIR/../../../scripts" && pwd)"

source "$ROOT_SCRIPTS_DIR/prompt_utils.sh"

unset SELF_DIR ROOT_SCRIPTS_DIR
