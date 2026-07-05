#!/bin/bash

function renameDartPackage() {
  local src_package
  local target_package

  read -rp "Enter source package name: " src_package
  read -rp "Enter target package name: " target_package

  if [[ -z "$src_package" || -z "$target_package" ]]; then
      echo "Error: Both package names are required, skipping."
      return 1
  fi

  replace_text_in_files "$src_package" "$target_package"

  echo "✅ Dart package name replacement completed."
}
