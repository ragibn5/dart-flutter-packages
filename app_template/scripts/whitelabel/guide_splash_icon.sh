#!/bin/bash

function showSplashIconChangeGuide() {
  echo "▶️ Splash icon change guide"
  echo "⚠️ IMPORTANT: All changes below must be done in the target (copied) project, not the template."
  echo "📁 Target project: $PWD"
  echo
  echo "📁 • Open each flavor's config file:"
  echo "     - $PWD/flutter_native_splash-dev.yaml   (for the 'dev' flavor)"
  echo "     - $PWD/flutter_native_splash-exp.yaml   (for the 'exp' flavor)"
  echo "     - $PWD/flutter_native_splash-stage.yaml (for the 'stage' flavor)"
  echo "     - $PWD/flutter_native_splash-prod.yaml  (for the 'prod' flavor)"
  echo "🛠️ • Customize settings in each file, such as:"
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
