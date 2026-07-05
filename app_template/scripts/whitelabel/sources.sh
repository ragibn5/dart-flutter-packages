#!/bin/bash

WLABEL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WLABEL_SHARED="$(cd "$WLABEL_DIR/../../../scripts" && pwd)"

source "$WLABEL_SHARED/flutter_utils.sh"
source "$WLABEL_SHARED/prompt_utils.sh"
source "$WLABEL_SHARED/project_utils.sh"

source "$WLABEL_DIR/resolve_target.sh"
source "$WLABEL_DIR/clean.sh"
source "$WLABEL_DIR/rename_dart_package.sh"
source "$WLABEL_DIR/rename_platform_package.sh"
source "$WLABEL_DIR/guide_app_name.sh"
source "$WLABEL_DIR/guide_launcher_icon.sh"
source "$WLABEL_DIR/guide_splash_icon.sh"
source "$WLABEL_DIR/guide_firebase.sh"
source "$WLABEL_DIR/final_todos.sh"

unset WLABEL_DIR WLABEL_SHARED
