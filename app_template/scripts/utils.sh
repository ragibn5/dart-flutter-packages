find_project_root() {
  local dir
  dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  while [[ "$dir" != "/" ]]; do
    [[ -f "$dir/pubspec.yaml" ]] && echo "$dir" && return 0
    dir="$(dirname "$dir")"
  done
  echo "Error: could not find project root" >&2
  return 1
}

get_flutter_cmd() {
    if [ -n "${FLUTTER:-}" ]; then
        echo "$FLUTTER"
    elif command -v fvm &>/dev/null; then
        echo "fvm flutter"
    else
        echo "flutter"
    fi
}

get_dart_cmd() {
    if [ -n "${DART:-}" ]; then
        echo "$DART"
    elif command -v fvm &>/dev/null; then
        echo "fvm dart"
    else
        echo "dart"
    fi
}