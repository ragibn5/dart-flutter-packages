#!/bin/bash

function showSplashIconChangeGuide() {
  echo "▶️ Splash icon change guide"
  echo "📁 • Locate the flavor-specific config files used by the splash icon generator tool."
  echo "     These files are named like: **flutter_native_splash-<flavor-name>.yaml**"
  echo "     where <flavor-name> can be 'dev', 'exp', 'stage', or 'prod'."
  echo "🛠️ • Open each config file and customize settings as needed, such as:"
  echo "     - Update image paths"
  echo "     - Set background colors"
  echo "     - Enable or disable specific options"
  echo "     - Or anything else, see https://pub.dev/packages/flutter_native_splash."
  echo "     Follow the detailed documentation on the config files to provide proper images and other configs."
  echo "     Also, you do not have to run any commands separately, even if the doc mentions to run any."
  echo "🎯 • Before continuing, make sure:"
  echo "     - The image paths are valid and points to the desired images."
  echo "     - The images follow the strict requirements described inside the config files."

  if confirm_yes_no "Generate splash icons?"; then
    $(get_dart_cmd) run flutter_native_splash:create --all-flavors
  fi
  echo "✅ Splash icon change guide"
}
