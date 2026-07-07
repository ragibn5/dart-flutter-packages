confirm_yes_no() {
  local question="$1"

  read -rp "$question [y/n]: " -n 1 response
  echo
  case "$response" in
    [yY]|[yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
}



