confirm_yes_no() {
  local question="$1"

  read -rp "$question [y/n]: " response
  case "$response" in
    [yY]|[yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
}

confirm_and_execute() {
  local question="$1"
  local command="$2"
  local response

  read -rp "$question [y/n/q]: " -e response

  case "$response" in
    [yY]|[yY][eE][sS])
      echo "➡️ Executing: $command"
      eval "$command"
      ;;
    [qQ]|[qQ][uU][iI][tT])
      echo "❌ Exiting..."
      exit 0
      ;;
    *)
      echo "⏭️ Skipping..."
      ;;
  esac
}

ask_and_run_function() {
  local question="$1"
  local function_name="$2"
  local response

  echo ""
  read -rp "$question [y/n/q]: " response

  case "$response" in
    [yY]|[yY][eE][sS])
      $function_name
      ;;
    [qQ]|[qQ][uU][iI][tT])
      echo "❌ Exiting..."
      exit 0
      ;;
    *)
      echo "⏭️ Skipping..."
      ;;
  esac
}

