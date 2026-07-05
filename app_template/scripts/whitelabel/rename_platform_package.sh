#!/bin/bash

function renamePlatformPackage() {
  local src_package
  local target_package

  read -rp "Enter source package name: " src_package
  read -rp "Enter target package name: " target_package

  if [[ -z "$src_package" || -z "$target_package" ]]; then
      echo "Error: Both package names are required, skipping."
      return 1
  fi

  echo "Replacing package name occurrences ..."
  replace_text_in_files "$src_package" "$target_package"

  local src_path="android/app/src/main/kotlin/${src_package//.//}"
  local target_path="android/app/src/main/kotlin/${target_package//.//}"

  mkdir -p "$(dirname "$target_path")"
  if [[ -d "$src_path" ]]; then
    mv "$src_path" "$target_path"
    echo "Moved directory from $src_path to $target_path"
  else
    echo "Warning: Source directory $src_path does not exist"
  fi

  echo "✅ Platform package name replacement completed."
}
