/// A user provider plugin for android.
library;

import 'package:user_provider_android/src/models/user_identity.dart';
import 'package:user_provider_android/user_provider_android_platform_interface.dart';

export 'src/models/user_identity.dart';

class UserProviderAndroid {
  Future<UserIdentity> getIdentity() {
    return UserProviderAndroidPlatform.instance.getIdentity();
  }
}
