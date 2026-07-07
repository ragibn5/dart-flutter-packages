#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/sources.sh"

STEPS=(
  "cleanProject:Project Cleanup"
  "renameDartPackage:Dart package name replacement"
  "renamePlatformPackage:Platform package name replacement"
  "showAppNameChangeGuide:App name change guide"
  "showLauncherIconChangeGuide:Launcher icon change guide"
  "showSplashIconChangeGuide:Splash icon change guide"
  "showFirebaseProjectSetupGuide:Firebase project setup guide"
)

run_step() {
  local index="$1"
  local entry="${STEPS[$index]}"
  local func_name="${entry%%:*}"
  $func_name
}

select_step() {
  local num_steps=${#STEPS[@]}
  echo ""
  echo "Select a step:"
  for i in "${!STEPS[@]}"; do
    local display="${STEPS[$i]#*:}"
    echo "  $((i + 1))) $display"
  done
  echo "  $((num_steps + 1))) Done - proceed to final setup"
  echo "  $((num_steps + 2))) Exit"

  local choice
  read -rp "Enter choice [1-$((num_steps + 2))]: " choice

  echo ""

  if [[ "$choice" =~ ^[0-9]+$ ]]; then
    return "$choice"
  else
    echo "Invalid choice."
    return 255
  fi
}

main() {
  echo -e "\n[Project Setup]"

  local template_root
  local target_dir

  template_root="$(find_project_root)"
  cd "$template_root" || exit 1
  echo "Changed working dir to current project root: $template_root"

  target_dir="$(resolveTarget "$template_root")" || exit 1
  cd "$target_dir" || {
    echo "Error: Failed to change to target directory '$target_dir'."
    exit 1
  }
  echo "Changed working dir to new project root: $target_dir"

  if [ ! -f "pubspec.yaml" ]; then
    echo "Error: Not a flutter project root, exiting."
    exit 1
  fi

  while true; do
    select_step
    local choice=$?

    if [ "$choice" -ge 1 ] && [ "$choice" -le "${#STEPS[@]}" ]; then
      run_step $((choice - 1))
    elif [ "$choice" -eq "$((${#STEPS[@]} + 1))" ]; then
      break
    elif [ "$choice" -eq "$((${#STEPS[@]} + 2))" ]; then
      echo "Exiting."
      exit 0
    else
      echo "Invalid choice."
    fi
  done

  echo -e "\nCleaning the project again, just in case they were automatically recreated by IDE..."
  cleanProject

  echo -e "\nRunning pub get ..."
  $(get_flutter_cmd) pub get

  showFinalTodos
}

main "$@"
