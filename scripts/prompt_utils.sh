confirm_yes_no() {
  local question="$1"

  read -rp "$question [y/n]: " response
  case "$response" in
    [yY]|[yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
}

prompt_with_default() {
  local prompt="$1"
  local default_value="$2"
  read -rp "${prompt} [${default_value}]: " input
  echo "${input:-$default_value}"
}
