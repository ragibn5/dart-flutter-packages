#!/bin/bash

function main() {
  echo -e "\n[Project Setup]"

  local input_target_dir
  local resolved_target_dir

  # Take in the path as input (can be relative)
  read -rp "Enter project root: " input_target_dir

  # Check if input is empty
  if [ -z "$input_target_dir" ]; then
    echo "Error: No input provided, exiting."
    exit 1
  fi

  if ! [ -d "$input_target_dir" ]; then
    echo "Error: '$input_target_dir' is not a valid directory, exiting."
    exit 1
  fi

  # Check for existence of the real path
  if ! resolved_target_dir=$(realpath "$input_target_dir"); then
    echo "Error: Could not resolve path '$input_target_dir', exiting."
    exit 1
  fi

  # Change to resolved directory
  cd "$resolved_target_dir" || {
    echo "Error: Failed to change to target directory '$resolved_target_dir'."
    exit 1
  }
  echo "Changed working directory to: $resolved_target_dir"

  # Ensure that the target path is a flutter project
  if [ ! -f "pubspec.yaml" ]; then
    echo "Error: Not a flutter project root, exiting."
    exit 1
  fi

  # Ready to run all steps with user confirmation
  askAndRunFunction "[Project Cleanup]" cleanProject
  askAndRunFunction "[Dart package name replacement]" renameDartPackage
  askAndRunFunction "[Platform package name replacement]" renamePlatformPackage
  askAndRunFunction "[App name change guide]" showAppNameChangeGuide
  askAndRunFunction "[Launcher icon change guide]" showLauncherIconChangeGuide
  askAndRunFunction "[Splash icon change guide]" showSplashIconChangeGuide
  askAndRunFunction "[Firebase project setup guide]" showFirebaseProjectSetupGuide

  echo -e "\nCleaning the project again, just in case they were automatically recreated by IDE..."
  cleanProject

  echo -e "\n Running pub get ..."
  $(getFlutterCmd) pub get

  showFinalTodos
}

function cleanProject() {
  local flutter_cmd
  flutter_cmd=$(getFlutterCmd)

  echo "Removing build directories and generated files ..."
  rm -rf \
    build/ \
    pubspec.lock \
    .dart_tool/ \
    .packages \
    .flutter-plugins \
    .flutter-plugins-dependencies \
    android/build/ \
    android/.cxx/ \
    android/app/.cxx/ \
    android/app/.gradle/ \
    ios/build/ \
    ios/.symlinks/ \
    ios/Pods/ \
    ios/PodFile.lock \
    linux/build/ \
    macos/build/ \
    windows/build/ \
    .idea/ \
    ./*.iml \
    android/*.iml

  echo "Running flutter clean ..."
  $flutter_cmd clean

  echo "✅ Project cleanup completed."
}

function renameDartPackage() {
  # Controls
  local src_package
  local target_package

  # Get user input
  read -rp "Enter source package name: " src_package
  read -rp "Enter target package name: " target_package

  # Basic validation
  if [[ -z "$src_package" || -z "$target_package" ]]; then
      echo "Error: Both package names are required, skipping."
      return 1
  fi

  replaceTextInFiles "$src_package" "$target_package"

  echo "✅ Dart package name replacement completed."
}

function renamePlatformPackage() {
  # Controls
  local src_package
  local target_package

  # Get user input
  read -rp "Enter source package name: " src_package
  read -rp "Enter target package name: " target_package

  # Basic validation
  if [[ -z "$src_package" || -z "$target_package" ]]; then
      echo "Error: Both package names are required, skipping."
      return 1
  fi

  echo "Replacing package name occurrences ..."
  replaceTextInFiles "$src_package" "$target_package"

  # Convert package names to directory paths
  local src_path="android/app/src/main/kotlin/${src_package//.//}"
  local target_path="android/app/src/main/kotlin/${target_package//.//}"

  # Fix android package directory structure
  # Create target directory structure if it doesn't exist
  mkdir -p "$(dirname "$target_path")"
  # Move contents from old package dir to new one
  if [[ -d "$src_path" ]]; then
    mv "$src_path" "$target_path"
    echo "Moved directory from $src_path to $target_path"
  else
    echo "Warning: Source directory $src_path does not exist"
  fi

  echo "✅ Platform package name replacement completed."
}

function showAppNameChangeGuide() {
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

  local response
  read -rp "Press 'Enter' to continue or 'q' to quit: " response

  if [[ "$response" == "q" || "$response" == "Q" ]]; then
    echo "Exiting..."
    exit 0
  fi

  echo "✅ App name change guide completed."
}

function showLauncherIconChangeGuide() {
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
  echo "⚠️  • iOS-specific warning (launcher generator package bug):"
  echo "     The tool used to generate launcher may corrupt the file at: ios/Runner.xcodeproj/project.pbxproj."
  echo "     After running the generation command, open this file and:"
  echo "     • Remove any gibberish or unexpected content added at the end of the file."
  echo "     • Replace any lines like:"
  echo "         ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = AppIcon-<flavor-name>;"
  echo "       with:"
  echo "         ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;"
  echo "       (Replace <flavor-name> with: dev, exp, stage, or prod)"
  echo "     • Then, in Xcode, go to the *Build Settings* tab."
  echo "       Search for *Primary App Icon Set Name* and make sure its value matches the expected one shown here:"
  echo "       assets/external/guides/ios_launcher_icon_flavored_values.jpeg"

  confirmAndExecute "Generate launcher icons?" "$(getDartCmd) run flutter_launcher_icons"
}

function showSplashIconChangeGuide() {
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

  confirmAndExecute "Generate splash icons?" "$(getDartCmd) run flutter_native_splash:create --all-flavors"
}

function showFirebaseProjectSetupGuide() {
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

  local response
  read -rp "▶️ Press 'y' to run the script, 'n' to skip, or 'q' to quit: " response

  case "$response" in
    [qQ])
      echo "Exiting..."
      exit 0
      ;;
    [yY])
      firebase login
      if [ -f "./firebase_setup.sh" ]; then
        chmod +x ./firebase_setup.sh


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

        confirmAndExecute "Run firebase_setup.sh script for DEV flavor?: " "./firebase_setup.sh dev"
        confirmAndExecute "Run firebase_setup.sh script for EXP flavor?: " "./firebase_setup.sh exp"
        confirmAndExecute "Run firebase_setup.sh script for STAGE flavor?: " "./firebase_setup.sh stage"
        confirmAndExecute "Run firebase_setup.sh script for PROD flavor?: " "./firebase_setup.sh prod"

        echo "✅ Firebase project setup completed."
      else
        echo "❌ Error: firebase_setup.sh not found in the current directory."
        echo "Please ensure the file exists in $(pwd) and try again."
      fi
      ;;
    *)
      echo "⏭️ Firebase project setup skipped."
      ;;
  esac
}

function showFinalTodos() {
  echo ""
  echo "🎯 Congratulations! You’ve successfully set up the project."
  echo
  echo "🔄 Next steps:"
  echo "• Restart your IDE — it's recommended to clean the IDE cache beforehand."
  echo
  echo "🧹 Optional cleanup:"
  echo "• You can safely delete this script file afterwards."
  echo
  echo "🛠️ Update the following to reflect your project:"
  echo "• 📄 README.md"
  echo "• 📄 pubspec.yaml (update these fields):"
  echo "  - name"
  echo "  - description"
  echo "  - repository"
  echo "  - issue_tracker"
  echo "  - homepage"
  echo "  - And anything other that reflects any template project property."
  echo
  echo "⚠️ No matter what you do, XCode will have some issues:"
  echo "- Make sure we have GoogleService-Info.plist inside ios dir."
  echo "- If not, copy ios/Config/Firebase/dev/GoogleService-Info.plist and paste it to ios folder."
  echo "- If there are any issue related to pod and Podfile, delete Podfile.lock and then run pod install or pod repo update."
  echo
  echo "🎯 Verify the project setup by running it into all platforms."
  echo
  echo "📚 If anything seems off, refer to the README.md in the original template project."
}


function confirmAndExecute() {
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

function askAndRunFunction() {
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

function replaceTextInFiles() {
  local src_text="$1"
  local target_text="$2"

  # Controls
  local match_file
  local count_file
  local total_occurrences
  local confirm

  # Basic validation
  if [[ -z "$src_text" || -z "$target_text" ]]; then
      echo "Error: Both source and target text are required."
      return 1
  fi

  # Temporary files for tracking matches
  match_file=$(mktemp)
  count_file=$(mktemp)
  echo "0" > "$count_file"

  # Find matches using fixed-string grep (-F) to avoid regex interpretation
  find . -type f | while read -r file; do
      # Skip binary files
      if grep -Iq "^" "$file"; then
          # Get matching lines with fixed-string matching
          matches=$(grep -nF "$src_text" "$file")
          if [[ -n "$matches" ]]; then
              # Store file and matches
              echo -e "$file" >> "$match_file"

              # Update total count
              total=$(cat "$count_file")
              count=$(echo "$matches" | wc -l)
              echo $((total + count)) > "$count_file"
          fi
      fi
  done

  total_occurrences=$(cat "$count_file")
  if [[ $total_occurrences -eq 0 ]]; then
      echo "No matches found!"
      rm -f "$match_file" "$count_file"
      return 0
  fi

  # Display grouped preview with highlighting
  echo "$total_occurrences matches found in following files:"
  cat "$match_file"

  # Ask for confirmation
  read -rp "Replace \"$src_text\" with \"$target_text\" in all the files? [y/N]: " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
      echo "Cancelled."
      rm -f "$match_file" "$count_file"
      return 0
  fi

  # Perform replacement
  grep "^\./" "$match_file" | while read -r file; do
      local safe_src
      local safe_new

      safe_src=$(printf '%s\n' "$src_text" | sed 's/[\/&]/\\&/g')
      safe_new=$(printf '%s\n' "$target_text" | sed 's/[\/&]/\\&/g')

      sed -i "" "s/$safe_src/$safe_new/g" "$file"
      echo "Updated: $file"
  done

  rm -f "$match_file" "$count_file"
}

function getDartCmd() {
    if [ -d "$(pwd)/.fvm/flutter_sdk" ]; then
      echo "fvm dart"
    else
      echo "dart"
    fi
}

function getFlutterCmd() {
    if [ -d "$(pwd)/.fvm/flutter_sdk" ]; then
      echo "fvm flutter"
    else
      echo "flutter"
    fi
}

# Entry point
main "$@"