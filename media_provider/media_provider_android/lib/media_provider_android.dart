/// A media provider plugin for android.
library;

import 'package:media_provider_android/media_provider_android_platform_interface.dart';
import 'package:media_provider_android/src/android_media_item.dart';
import 'package:media_provider_android/src/android_media_query.dart';

export 'src/android_media_item.dart';
export 'src/android_media_query.dart';
export 'src/android_media_type.dart';
export 'src/android_storage_volume_info.dart';

class MediaProviderAndroid {
  /// Queries `MediaStore` as per the given query.
  ///
  /// See the [AndroidMediaQuery] for more info.
  Future<List<AndroidMediaItem>> getMedia(AndroidMediaQuery query) {
    return MediaProviderAndroidPlatform.instance.getMedia(query);
  }
}
