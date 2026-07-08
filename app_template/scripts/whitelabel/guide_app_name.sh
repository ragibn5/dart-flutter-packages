#!/bin/bash

function showAppNameChangeGuide() {
  echo "▶️ App name change guide"
  echo "⚠️ IMPORTANT: All changes below must be done in the target (copied) project, not the template."
  echo "📁 Target project: $PWD"
  echo
  echo "🤖 ANDROID:"
  echo "   • Open each flavor's strings.xml and change the 'app_name' value:"
  echo "     - $PWD/android/app/src/dev/res/values/strings.xml   (for the 'dev' flavor)"
  echo "     - $PWD/android/app/src/exp/res/values/strings.xml   (for the 'exp' flavor)"
  echo "     - $PWD/android/app/src/stage/res/values/strings.xml (for the 'stage' flavor)"
  echo "     - $PWD/android/app/src/prod/res/values/strings.xml  (for the 'prod' flavor)"
  echo "     - $PWD/android/app/src/main/res/values/strings.xml  (default, used when no flavor is specified)"
  echo "🍎 iOS:"
  echo "   1. Open $PWD/ios/Runner.xcworkspace in Xcode."
  echo "   2. Click 'Runner' from the project navigator (usually the first item)."
  echo "   3. Select 'Runner' from the 'TARGETS' section (usually located at right of project navigator)"
  echo "   4. Select the 'Build Settings' tab and search for 'APP_DISPLAY_NAME'."
  echo "   5. Expand the 'APP_DISPLAY_NAME' option."
  echo "   6. Set your desired names for each flavor."
  echo "📝 NOTE: We have not covered localized app name in this guide."

  read -rp "Press 'Enter' to continue... "
  echo "✅ App name change guide completed."
}
