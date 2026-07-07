#!/bin/bash

function task_launcher_icons() {
  # ── Guide ──────────────────────────────────────────────
  echo "📁 • Locate the flavor-specific config files used by the launcher icon generator tool."
  echo "     These files are named like: **flutter_launcher_icons-<flavor-name>.yaml**"
  echo "     where <flavor-name> can be 'dev', 'exp', 'stage', or 'prod'."
  echo "🛠️ • Open each config file and customize settings as needed, such as:"
  echo "     - Update image paths"
  echo "     - Set background colors"
  echo "     - Enable or disable specific options"
  echo "     - Or anything else, see https://pub.dev/packages/flutter_launcher_icons."
  echo "     Follow the detailed documentation on the config files to provide proper images and other configs."
  echo "     Also, you do not have to run any commands separately, even if the doc mentions to run any."
  echo "🎯 • Before continuing, make sure:"
  echo "     - The image paths are valid and points to the desired images."
  echo "     - The images follow the strict requirements described inside the config files."

  # ── Capture ────────────────────────────────────────────
  local pbxproj_file="ios/Runner.xcodeproj/project.pbxproj"
  local backup_file=""
  local key="ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS"
  if [[ -f "$pbxproj_file" ]]; then
    backup_file=$(mktemp)
    while IFS= read -r line; do
      line_num="${line%%:*}"
      rest="${line#*:}"
      value="${rest#*= }"
      value="${value%;}"
      echo "$line_num:$value"
    done < <(grep -n "$key" "$pbxproj_file") > "$backup_file"
  fi

  # ── Command ────────────────────────────────────────────
  confirm_and_execute "Generate launcher icons?" "$(get_dart_cmd) run flutter_launcher_icons"

  # ── Fix ────────────────────────────────────────────────
  if [[ -n "$backup_file" && -f "$backup_file" ]]; then
    echo ""
    echo "🔧 Performing known bug fixes..."
    local fixed=0
    local had_error=0

    while IFS=: read -r line_num original_value; do
      [[ -z "$line_num" ]] && continue

      local current_line
      current_line=$(sed -n "${line_num}p" "$pbxproj_file" 2>/dev/null)

      if [[ -z "$current_line" || ! "$current_line" =~ $key ]]; then
        echo "    ❌ Line $line_num in $pbxproj_file does not match expected state."
        echo "       The file structure may have changed. Please revert it manually."
        had_error=1
        break
      fi

      local corrupted_regex="${key}"'[[:space:]]*=[[:space:]]*AppIcon-'
      if [[ "$current_line" =~ $corrupted_regex ]]; then
        sed -i "" "${line_num}s/$key = AppIcon-[^;]*;/$key = $original_value;/" "$pbxproj_file"
        ((fixed++))
      fi
    done < "$backup_file"

    if [[ "$fixed" -gt 0 ]]; then
      echo "    ✅ Restored $fixed corrupted entries for $key."
    fi

    rm -f "$backup_file"

    if [[ "$had_error" -eq 1 ]]; then
      return 1
    fi
  fi
}

function showLauncherIconChangeGuide() {
  local tasks=(
    task_launcher_icons
  )

  for task_func in "${tasks[@]}"; do
    $task_func
  done
}
