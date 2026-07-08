#!/bin/bash

function showFinalTodos() {
  echo ""
  echo "🎯 Congratulations! You’ve successfully set up the project."
  echo "⚠️ IMPORTANT: All changes below must be done in the target (copied) project, not the template."
  echo "📁 Target project: $PWD"
  echo
  echo "🔄 Next steps:"
  echo "• Restart your IDE — it's recommended to clean the IDE cache beforehand."
  echo
  echo "🧹 Optional cleanup:"
  echo "• You can safely delete this script file afterwards."
  echo
  echo "🛠️ Update these files to reflect your project:"
  echo "• $PWD/README.md"
  echo "• $PWD/pubspec.yaml (update these fields):"
  echo "  - name"
  echo "  - description"
  echo "  - repository"
  echo "  - issue_tracker"
  echo "  - homepage"
  echo "  - And anything else that reflects a template project property."
  echo
  echo "⚠️ No matter what you do, XCode will have some issues:"
  echo "- Make sure $PWD/ios/GoogleService-Info.plist exists."
  echo "- If not, copy $PWD/ios/Config/Firebase/dev/GoogleService-Info.plist to $PWD/ios/."
  echo "- If there are any issue related to pod and Podfile, delete $PWD/ios/Podfile.lock and then run \"pod install\" or \"pod repo update\"."
  echo
  echo "🎯 Verify the project setup by running it into all platforms."
  echo
  echo "📚 If anything seems off, refer to the README.md in the original template project."
}
