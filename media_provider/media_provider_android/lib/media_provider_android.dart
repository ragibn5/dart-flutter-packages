/// A media provider plugin for android.
library;

import 'package:media_provider_android/media_provider_android_platform_interface.dart';
import 'package:media_provider_android/src/models/media_item.dart';
import 'package:media_provider_android/src/models/query_spec.dart';
import 'package:media_provider_android/src/models/volume_info.dart';

export 'src/models/media_item.dart';
export 'src/models/query_spec.dart';
export 'src/models/media_type.dart';
export 'src/models/volume_info.dart';
export 'src/models/volume_spec.dart';

class MediaProviderAndroid {
  /// Get all storage volumes.
  Future<List<VolumeInfo>> getVolumes() {
    return MediaProviderAndroidPlatform.instance.getVolumes();
  }

  /// Queries `MediaStore` as per the given query.
  Future<List<MediaItem>> getMedia(QuerySpec query) {
    return MediaProviderAndroidPlatform.instance.getMedia(query);
  }
}
