#!/bin/bash

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
