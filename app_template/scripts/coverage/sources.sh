#!/bin/bash

COV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COV_SHARED="$(cd "$COV_DIR/../../../scripts" && pwd)"

source "$COV_SHARED/project_utils.sh"
source "$COV_SHARED/flutter_utils.sh"
source "$COV_DIR/exclusions.sh"

unset COV_DIR COV_SHARED
