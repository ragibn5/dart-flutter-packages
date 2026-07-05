#!/bin/bash

function cleanProject() {
  local flutter_cmd
  flutter_cmd=$(get_flutter_cmd)

  echo "Removing build directories and generated files ..."
  rm -rf \
    build/ \
    pubspec.lock \
    .dart_tool/ \
    .packages \
    .flutter-plugins \
    .flutter-plugins-dependencies \
    android/build/ \
    android/.cxx/ \
    android/app/.cxx/ \
    android/app/.gradle/ \
    ios/build/ \
    ios/.symlinks/ \
    ios/Pods/ \
    ios/PodFile.lock \
    linux/build/ \
    macos/build/ \
    windows/build/ \
    .idea/ \
    ./*.iml \
    android/*.iml

  echo "Running flutter clean ..."
  $flutter_cmd clean

  echo "✅ Project cleanup completed."
}
