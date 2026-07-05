#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/sources.sh"

function main() {
  echo -e "\n[Project Setup]"

  local input_target_dir
  local resolved_target_dir

  read -rp "Enter project root: " input_target_dir

  if [ -z "$input_target_dir" ]; then
    echo "Error: No input provided, exiting."
    exit 1
  fi

  if ! [ -d "$input_target_dir" ]; then
    echo "Error: '$input_target_dir' is not a valid directory, exiting."
    exit 1
  fi

  if ! resolved_target_dir=$(realpath "$input_target_dir"); then
    echo "Error: Could not resolve path '$input_target_dir', exiting."
    exit 1
  fi

  cd "$resolved_target_dir" || {
    echo "Error: Failed to change to target directory '$resolved_target_dir'."
    exit 1
  }
  echo "Changed working directory to: $resolved_target_dir"

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
