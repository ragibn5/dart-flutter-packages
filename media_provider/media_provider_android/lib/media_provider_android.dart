/// A media provider plugin for android.
library;

import 'package:media_provider_android/media_provider_android_platform_interface.dart';
import 'package:media_provider_android/src/io/media_read_session.dart';
import 'package:media_provider_android/src/models/media_item.dart';
import 'package:media_provider_android/src/models/open_media_read_request.dart';
import 'package:media_provider_android/src/models/query_spec.dart';
import 'package:media_provider_android/src/models/volume_info.dart';

export 'src/io/media_read_session.dart';
export 'src/models/media_item.dart';
export 'src/models/media_read_request.dart';
export 'src/models/media_type.dart';
export 'src/models/query_spec.dart';
export 'src/models/volume_identity.dart';
export 'src/models/volume_info.dart';
export 'src/models/volume_spec.dart';
export 'src/models/volume_state.dart';
export 'src/models/volume_type.dart';

class MediaProviderAndroid {
  /// Get all storage volumes.
  ///
  /// See the [VolumeInfo] for more info.
  Future<List<VolumeInfo>> getVolumes() {
    return MediaProviderAndroidPlatform.instance.getVolumes();
  }

  /// Queries `MediaStore` as per the given query.
  ///
  /// See the [QuerySpec] for more info.
  Future<List<MediaItem>> getMedia(QuerySpec query) {
    return MediaProviderAndroidPlatform.instance.getMedia(query);
  }

  /// Opens a session for reading the item [request] points to.
  ///
  /// See [MediaReadSession] for more info.
  Future<MediaReadSession> openReadSession(OpenMediaReadRequest request) {
    return MediaProviderAndroidPlatform.instance.openReadSession(request);
  }
}
