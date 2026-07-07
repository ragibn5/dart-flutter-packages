#!/bin/bash

function resolveTarget() {
  local template_root="$1"
  local input_target_dir
  local resolved_target_dir

  read -rp "New project path (absolute/relative - must be outside the template): " input_target_dir

  if [ -z "$input_target_dir" ]; then
    echo "Error: No input provided, exiting." >&2
    exit 1
  fi

  resolved_target_dir=$(realpath -m "$input_target_dir" 2>/dev/null) || resolved_target_dir=$(python3 -c "import os.path; print(os.path.abspath('$input_target_dir'))" 2>/dev/null) || resolved_target_dir="$input_target_dir"

  if [[ "$resolved_target_dir" == "$template_root"* ]]; then
    echo "Error: Target path '$resolved_target_dir' is inside the template project. Choose a path outside." >&2
    exit 1
  fi

  if [ ! -d "$resolved_target_dir" ]; then
    echo "Copying template to '$resolved_target_dir' ..." >&2
    mkdir -p "$(dirname "$resolved_target_dir")"
    cp -a "$template_root" "$resolved_target_dir"
    echo "✅ Template copied." >&2

  else
    echo "⚠️Target directory '$resolved_target_dir' already exists." >&2
    if [ -n "$(ls -A "$resolved_target_dir" 2>/dev/null)" ]; then
      if confirm_yes_no "Are you sure you want to continue?"; then
        echo "Continuing with existing directory..." >&2
      else
        echo "Exiting..." >&2
        exit 1
      fi
    fi
  fi

  echo "$resolved_target_dir"
}
