#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/sources.sh"

function main() {
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

  ask_and_run_function "[Project Cleanup]" cleanProject
  ask_and_run_function "[Dart package name replacement]" renameDartPackage
  ask_and_run_function "[Platform package name replacement]" renamePlatformPackage
  ask_and_run_function "[App name change guide]" showAppNameChangeGuide
  ask_and_run_function "[Launcher icon change guide]" showLauncherIconChangeGuide
  ask_and_run_function "[Splash icon change guide]" showSplashIconChangeGuide
  ask_and_run_function "[Firebase project setup guide]" showFirebaseProjectSetupGuide

  echo -e "\nCleaning the project again, just in case they were automatically recreated by IDE..."
  cleanProject

  echo -e "\n Running pub get ..."
  $(get_flutter_cmd) pub get

  showFinalTodos
}

main "$@"
