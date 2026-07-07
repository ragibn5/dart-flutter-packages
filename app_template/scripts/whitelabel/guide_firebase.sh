#!/bin/bash

function showFirebaseProjectSetupGuide() {
  echo "▶️ Firebase project setup guide"
  echo "📁 • Locate and open the firebase_setup.sh file."
  echo "🛠️ • Modify the default value for the following (inside the switch case block where existing defaults are defined):"
  echo " ️   - Firebase project id: Specified by 'default_project'"
  echo " ️   - iOS bundle id: Specified by 'default_ios_bundle'"
  echo " ️   - Android app id / package name: Specified by 'default_android_pkg'"
  echo "🎯 • Before running the script, make sure:"
  echo "     - You have created the firebase project."
  echo "     - You have changed the default values correctly."
  echo "     - You have firebase and flutterfire cli tools installed."
  echo "       Read the project README if you want to go through the installation process of these tools."
  echo "📝 NOTE: Please select 'Debug-<flavor-name>' variants as the build configuration if asked."

  ! confirm_yes_no "▶️ Press 'y' to run the script, 'n' to skip?" && echo "⏭️ Firebase project setup skipped." && return

  firebase login
  if [ ! -f "../firebase/firebase_setup.sh" ]; then
    echo "❌ Error: firebase_setup.sh not found in the current directory."
    echo "Please ensure the file exists in $(pwd) and try again."
    return
  fi

  chmod +x ../firebase/firebase_setup.sh
  firebase login:list
  echo "0 to continue"
  echo "1 to logout and login and continue"
  read -rp "Enter choice [0/1]: " choice

  if [[ "$choice" == "1" ]]; then
    firebase logout
    firebase login
  else
    firebase login
  fi

  confirm_yes_no "Run firebase_setup.sh script for DEV flavor?" && ../firebase/firebase_setup.sh dev
  confirm_yes_no "Run firebase_setup.sh script for EXP flavor?" && ../firebase/firebase_setup.sh exp
  confirm_yes_no "Run firebase_setup.sh script for STAGE flavor?" && ../firebase/firebase_setup.sh stage
  confirm_yes_no "Run firebase_setup.sh script for PROD flavor?" && ../firebase/firebase_setup.sh prod

  echo "✅ Firebase project setup completed."
}
