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