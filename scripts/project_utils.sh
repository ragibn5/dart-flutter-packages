find_project_root() {
  local dir="${1:-$PWD}"
  dir="$(cd "$dir" && pwd)"

  while [[ "$dir" != "/" ]]; do
    [[ -f "$dir/pubspec.yaml" ]] && echo "$dir" && return 0
    dir="$(dirname "$dir")"
  done

  echo "Error: could not find project root from $PWD" >&2
  return 1
}
