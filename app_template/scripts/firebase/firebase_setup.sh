#!/bin/bash

# Interactive script to generate Firebase configuration files for different environments/flavors
#
# Assuming you already created firebase projects for each flavor.
# For simplicity, we are using the same firebase project, but it is
# recommended to use different firebase project per flavor.
#
# Please change `default_project`, `default_ios_bundle` and `default_android_pkg`
# for each flavor. If the apps do not yet exist in firebase, they will be created.
#
# Finally, run this script file (from the run icon on top of the file).
# This will overwrite the existing related files with your firebase files.
# That is it to set up firebase for each flavors!

# Function to prompt user with default value
prompt_with_default() {
  local prompt="$1"
  local default_value="$2"
  read -rp "${prompt} [${default_value}]: " input
  echo "${input:-$default_value}"
}

# Prompt for flavor/environment
if [[ $# -eq 0 ]]; then
  read -rp "Enter environment flavor (dev/exp/stage/prod): " flavor
else
  flavor=$1
fi

# Validate flavor
case $flavor in
  dev|exp|stage|prod) ;;
  *)
    echo "Error: Invalid environment specified. Use 'dev', 'exp', 'stage', or 'prod'."
    exit 1
    ;;
esac

# Set default values based on flavor
case $flavor in
  dev)
    default_project="flutter-app-template-b1e3c"
    default_ios_bundle="com.ragibn5.fat.dev"
    default_android_pkg="com.ragibn5.fat.dev"
    ;;
  exp)
    default_project="flutter-app-template-b1e3c"
    default_ios_bundle="com.ragibn5.fat.exp"
    default_android_pkg="com.ragibn5.fat.exp"
    ;;
  stage)
    default_project="flutter-app-template-b1e3c"
    default_ios_bundle="com.ragibn5.fat.stage"
    default_android_pkg="com.ragibn5.fat.stage"
    ;;
  prod)
    default_project="flutter-app-template-b1e3c"
    default_ios_bundle="com.ragibn5.fat"
    default_android_pkg="com.ragibn5.fat"
    ;;
esac

# Prompt user for values with defaults
project=$(prompt_with_default "Enter Firebase project ID" "$default_project")
ios_bundle=$(prompt_with_default "Enter iOS bundle ID" "$default_ios_bundle")
android_pkg=$(prompt_with_default "Enter Android package name" "$default_android_pkg")

# Set default output paths
ios_out="ios/Config/Firebase/${flavor}/GoogleService-Info.plist"
android_out="android/app/src/${flavor}/google-services.json"
dart_out="lib/app/infrastructure/firebase/firebase_options_${flavor}.dart"

# Confirm with user
echo -e "\nGenerating Firebase configuration with:"
echo "Project: $project"
echo "iOS Bundle ID: $ios_bundle"
echo "Android Package: $android_pkg"
echo "iOS Output: $ios_out"
echo "Android Output: $android_out"
echo "Dart Output: $dart_out"

if ! confirm_yes_no "Continue?"; then
  echo "Aborted."
  exit 0
fi

# Create directories if they don't exist
mkdir -p "ios/Config/Firebase/${flavor}"
mkdir -p "android/app/src/${flavor}"
mkdir -p "lib/app/infrastructure/firebase"

# Run flutterfire command
echo -e "\nRunning flutterfire configure..."
flutterfire configure \
  --project="$project" \
  --out="$dart_out" \
  --ios-bundle-id="$ios_bundle" \
  --ios-out="$ios_out" \
  --android-package-name="$android_pkg" \
  --android-out="$android_out"

echo "Configuration complete for $flavor environment!"