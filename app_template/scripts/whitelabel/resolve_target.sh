#!/bin/bash

function resolveTarget() {
  local template_root="$1"
  local input_target_dir
  local resolved_target_dir

  echo "Template source: $template_root"
  read -rp "Enter project path: " input_target_dir

  if [ -z "$input_target_dir" ]; then
    echo "Error: No input provided, exiting."
    exit 1
  fi

  if ! resolved_target_dir=$(realpath "$input_target_dir" 2>/dev/null); then
    resolved_target_dir="$input_target_dir"
  fi

  if [ "$resolved_target_dir" = "$template_root" ]; then
    echo "Operating on the template project directly."

  elif [ ! -d "$resolved_target_dir" ]; then
    echo "Copying template to '$resolved_target_dir' ..."
    mkdir -p "$(dirname "$resolved_target_dir")"
    cp -a "$template_root" "$resolved_target_dir"
    echo "✅ Template copied."

  elif [ -d "$resolved_target_dir" ]; then
    echo "Operating on existing project at '$resolved_target_dir'."

  else
    echo "Error: Invalid path, exiting."
    exit 1
  fi

  echo "$resolved_target_dir"
}
