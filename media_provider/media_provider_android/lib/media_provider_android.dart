/// A media provider plugin for android.
library;

import 'package:media_provider_android/media_provider_android_platform_interface.dart';
import 'package:media_provider_android/src/android_media_item.dart';
import 'package:media_provider_android/src/android_media_type.dart';

export 'src/android_media_item.dart';
export 'src/android_media_type.dart';
export 'src/media_codec.dart';

class MediaProviderAndroid {
  /// Queries `MediaStore` for every item of the given [types].
  ///
  /// [types] must not be empty. Returns one [AndroidMediaItem] per matching
  /// row, in the order the queries returned them.
  Future<List<AndroidMediaItem>> getMedia(Set<AndroidMediaType> types) {
    return MediaProviderAndroidPlatform.instance.getMedia(types);
  }
}
