get_coverage_pct() {
  local lcov_file="${1:-coverage/lcov.info}"
  if [[ ! -f "$lcov_file" ]]; then
    echo "Error: coverage file not found: $lcov_file" >&2
    exit 1
  fi

  lcov --summary "$lcov_file" 2>&1 | awk '/lines\.*:/ {gsub(/%/, "", $2); print $2}' || true
}
