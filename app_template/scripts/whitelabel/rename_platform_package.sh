#!/bin/bash

# Android module's programming languages.
_ANDROID_PKG_LANGUAGES=("kotlin" "java")

# Android source set directories that may contain package-name-based kotlin/java folders.
# Add/remove entries here if you add/remove a flavor or source set.
_ANDROID_PKG_DIRS=(
  "main"
  "debug"
  "profile"
  "dev"
  "exp"
  "stage"
  "prod"
  "test"
  "testDev"
  "testExp"
  "testStage"
  "testProd"
  "androidTest"
  "androidTestDev"
  "androidTestExp"
  "androidTestStage"
  "androidTestProd"
)

_rename_platform_package_common() {
  local src_package="$1"
  local target_package="$2"
  echo "Searching for package name occurrences ..."
  replace_text_in_files "$src_package" "$target_package"
}

_rename_platform_package_android() {
  local src_package="$1"
  local target_package="$2"
  local src_rel_path="${src_package//.//}"
  local target_rel_path="${target_package//.//}"
  local moved_dirs=()

  for dir in "${_ANDROID_PKG_DIRS[@]}"; do
    for lang in "${_ANDROID_PKG_LANGUAGES[@]}"; do
      local src_path="android/app/src/$dir/$lang/$src_rel_path"
      local target_path="android/app/src/$dir/$lang/$target_rel_path"

      if [[ -d "$src_path" ]]; then
        mkdir -p "$(dirname "$target_path")"
        mv "$src_path" "$target_path"
        moved_dirs+=("$src_path -> $target_path")
      fi
    done
  done

  if [[ ${#moved_dirs[@]} -gt 0 ]]; then
    echo "Moving package directories..."
    for entry in "${moved_dirs[@]}"; do
      echo "Moved: $entry"
    done
  fi
}

_rename_platform_package_ios() {
  local src_package="$1"
  local target_package="$2"
  # iOS uses a flat directory structure — no package-based directories to move.
  :
}

function renamePlatformPackage() {
  local src_package
  local target_package

  read -rp "Enter source package name: " src_package
  read -rp "Enter target package name: " target_package

  if [[ -z "$src_package" || -z "$target_package" ]]; then
      echo "Error: Both package names are required, skipping."
      return 1
  fi

  if _rename_platform_package_common "$src_package" "$target_package"; then
    _rename_platform_package_android "$src_package" "$target_package"
    _rename_platform_package_ios "$src_package" "$target_package"
    echo "✅ Platform package name replacement completed."
  else
    echo "⏭️ Platform package name replacement cancelled."
  fi
}
