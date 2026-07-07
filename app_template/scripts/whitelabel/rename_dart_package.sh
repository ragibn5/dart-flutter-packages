#!/bin/bash

function renameDartPackage() {
  local src_package
  local target_package

  read -rp "Enter source package name (typically found in pubspec.yaml under 'name' key): " src_package
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
