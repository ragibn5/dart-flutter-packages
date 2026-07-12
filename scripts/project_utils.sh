find_project_root() {
  local dir="${1:-$PWD}"
  dir="$(cd "$dir" && pwd)"

  while [[ "$dir" != "/" ]]; do
    [[ -f "$dir/pubspec.yaml" ]] && echo "$dir" && return 0
    dir="$(dirname "$dir")"
  done

  echo "Error: could not find project root from $PWD." >&2
  return 1
}

get_current_dart_package() {
  grep "^name:" pubspec.yaml 2>/dev/null | sed 's/name: *//' | tr -d '"' | tr -d "'" | tr -d '[:space:]'
}

# Detects the current platform package name from the Android build.gradle.kts.
# Note: We assume the Android package name and iOS bundle ID are the same and
# use accordingly in other scripts.
get_current_platform_package() {
  grep "^ *applicationId = " android/app/build.gradle.kts 2>/dev/null | sed 's/.*= *//' | tr -d '"' | tr -d "'" | tr -d '[:space:]'
}
