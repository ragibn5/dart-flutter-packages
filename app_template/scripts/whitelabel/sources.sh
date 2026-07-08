#!/bin/bash

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_SCRIPTS_DIR="$(cd "$SELF_DIR/../../../scripts" && pwd)"
FIREBASE_SCRIPTS_DIR="$(cd "$SELF_DIR/../firebase" && pwd)"

source "$ROOT_SCRIPTS_DIR/flutter_utils.sh"
source "$ROOT_SCRIPTS_DIR/prompt_utils.sh"
source "$ROOT_SCRIPTS_DIR/project_utils.sh"
source "$ROOT_SCRIPTS_DIR/text_utils.sh"

source "$SELF_DIR/resolve_target.sh"
source "$SELF_DIR/clean.sh"
source "$SELF_DIR/rename_dart_package.sh"
source "$SELF_DIR/rename_platform_package.sh"
source "$SELF_DIR/guide_app_name.sh"
source "$SELF_DIR/guide_launcher_icon.sh"
source "$SELF_DIR/guide_splash_icon.sh"
source "$SELF_DIR/guide_firebase.sh"
source "$SELF_DIR/finalize.sh"
source "$SELF_DIR/show_final_todos.sh"
source "$SELF_DIR/exit.sh"

source "$FIREBASE_SCRIPTS_DIR/firebase_setup.sh"

unset SELF_DIR ROOT_SCRIPTS_DIR FIREBASE_SCRIPTS_DIR
