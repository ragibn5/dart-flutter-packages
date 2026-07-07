#!/bin/bash

function showLauncherIconChangeGuide() {
  echo "▶️ Launcher icon change guide"

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

  # ── Command + Fix ──────────────────────────────────────
  ! confirm_yes_no "Generate launcher icons?" && echo "✅ Launcher icon change guide" && return

  local pbxproj_file="ios/Runner.xcodeproj/project.pbxproj"
  local key="ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS"
  local backup_entries=()

  if [[ -f "$pbxproj_file" ]]; then
    while IFS= read -r line; do
      local line_num="${line%%:*}"
      local rest="${line#*:}"
      local value="${rest#*= }"
      backup_entries+=("${line_num}:${value%;}")
    done < <(grep -n "$key" "$pbxproj_file")
  fi

  $(get_dart_cmd) run flutter_launcher_icons

  if [[ ${#backup_entries[@]} -eq 0 ]]; then
    echo "✅ Launcher icon change guide"
    return
  fi

  echo ""
  echo "🔧 Performing known bug fixes..."
  local fixed=0

  for entry in "${backup_entries[@]}"; do
    local line_num="${entry%%:*}"
    local original_value="${entry#*:}"
    local current_line
    current_line=$(sed -n "${line_num}p" "$pbxproj_file" 2>/dev/null)

    if [[ -z "$current_line" || ! "$current_line" =~ $key ]]; then
      echo " ❌ Line $line_num in $pbxproj_file does not match expected state."
      echo "    The file structure may have changed. Please revert it manually."
      echo "✅ Launcher icon change guide"
      return 1
    fi

    local corrupted_regex="${key}"'[[:space:]]*=[[:space:]]*AppIcon-'
    if [[ "$current_line" =~ $corrupted_regex ]]; then
      sed -i "" "${line_num}s/$key = AppIcon-[^;]*;/$key = $original_value;/" "$pbxproj_file"
      ((fixed++))
    fi
  done

  if [[ "$fixed" -gt 0 ]]; then
    echo "✅ Restored $fixed corrupted entries for $key."
  fi

  echo "✅ Launcher icon change guide"
}
