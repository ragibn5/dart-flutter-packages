#!/bin/bash

function showAppNameChangeGuide() {
  echo "▶️ App name change guide"
  echo "🤖 ANDROID:"
  echo "   • Open android/app/src/<flavor-name>/res/values/strings.xml."
  echo "     <flavor-name> can be one of 'dev', 'exp', 'stage', or 'prod'."
  echo "   • For each flavor, change the 'app_name' key's value to your desired app name."
  echo "   • Similarly change the app name at android/app/src/main/res/values/strings.xml."
  echo "     This is the default app name, i.e., when you run the app without specifying any flavor."
  echo "🍎 iOS:"
  echo "   1. Open the iOS sub-project in Xcode."
  echo "   2. Click 'Runner' from the project navigator (usually the first item)."
  echo "   3. Select 'Runner' from the 'TARGETS' section (usually located at right of project navigator)"
  echo "   4. Select the 'Build Settings' tab and search for 'APP_DISPLAY_NAME'."
  echo "   5. Expand the 'APP_DISPLAY_NAME' option."
  echo "   6. Set your desired names for each flavor."
  echo "📝 NOTE: We have not covered localized app name in this guide."

  read -rp "Press 'Enter' to continue... "
  echo "✅ App name change guide completed."
}
