#!/bin/bash

function showFirebaseProjectSetupGuide() {
  echo "▶️ Firebase project setup guide"
  echo "⚠️ IMPORTANT: All changes below must be done in the target (copied) project, not the template."
  echo "📁 Target project: $PWD"
  echo
  echo "📁 • Open $PWD/scripts/firebase/firebase.env"
  echo "🛠️ • Modify the default values for each flavor: project ID, iOS bundle ID, and Android package name."
  echo "🎯 • Before continuing, make sure:"
  echo "     - You have created the Firebase projects."
  echo "     - You have changed the defaults in firebase.env correctly."
  echo "     - You have firebase and flutterfire cli tools installed."
  echo "       Read the project README if you want to go through the installation process of these tools."
  echo "📝 NOTE: Please select 'Debug-<flavor-name>' variants as the build configuration if asked."

  ! confirm_yes_no "▶️ Press 'y' to run the script, 'n' to skip?" && echo "⏭️ Firebase project setup skipped." && return

  firebase login
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

  confirm_yes_no "Run firebase_setup.sh script for DEV flavor?" && runFirebaseSetup dev
  confirm_yes_no "Run firebase_setup.sh script for EXP flavor?" && runFirebaseSetup exp
  confirm_yes_no "Run firebase_setup.sh script for STAGE flavor?" && runFirebaseSetup stage
  confirm_yes_no "Run firebase_setup.sh script for PROD flavor?" && runFirebaseSetup prod

  echo "✅ Firebase project setup completed."
}
