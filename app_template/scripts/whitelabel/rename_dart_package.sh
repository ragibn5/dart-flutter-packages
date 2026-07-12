#!/bin/bash

function renameDartPackage() {
  echo "▶️ Dart package name replacement"

  local current_dart_pkg
  current_dart_pkg=$(get_current_dart_package)

  local src_package
  local target_package

  src_package=$(prompt_with_default "Enter source package name" "$current_dart_pkg")
  read -rp "Enter target package name: " target_package

  if [[ -z "$src_package" || -z "$target_package" ]]; then
      echo "Error: Both package names are required, skipping."
      return 1
  fi

  if replace_text_in_files "$src_package" "$target_package"; then
    echo "✅ Dart package name replacement completed."
  else
    echo "⏭️ Dart package name replacement cancelled."
  fi
}
