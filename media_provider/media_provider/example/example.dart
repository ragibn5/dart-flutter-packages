import 'package:media_provider/media_provider.dart';

/// Reads media from the device's media library.
///
/// On Android this requires the `READ_MEDIA_IMAGES` and `READ_MEDIA_VIDEO`
/// permissions on Android 13 (API 33) and above, or `READ_EXTERNAL_STORAGE` on
/// Android 12 (API 32) and below.
Future<void> main() async {
  final mediaProvider = MediaProvider.instance;

  // [types] must not be empty. Every requested type is returned.
  final items = await mediaProvider.getMedia({
    MediaType.photo,
    MediaType.video,
  });

  for (final item in items) {
    final size = item.sizeInBytes;
    print(
      '${item.type.name} ${item.id}: ${item.name ?? '<unknown>'}'
      ' ${size == null ? '' : '($size bytes)'} ${item.uri}',
    );
  }

  // A single type can be requested on its own too.
  final photos = await mediaProvider.getMedia({MediaType.photo});
  print('${photos.length} of ${items.length} items are photos.');
}
