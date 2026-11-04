import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/src/models/open_thumbnail_read_request.dart';
import 'package:media_provider_android/src/models/thumbnail_size.dart';

import '../../helpers/fixtures.dart';

void main() {
  test('fromItemShouldUseItemUriAndGivenSize', () {
    expect(
      OpenThumbnailReadRequest.fromItem(
        photoItem,
        size: const ThumbnailSize(width: 256, height: 128),
      ),
      const OpenThumbnailReadRequest(
        contentUri: 'content://media/external/images/media/1',
        size: ThumbnailSize(width: 256, height: 128),
      ),
    );
  });

  test('toJsonShouldEncodeSizeAsMap', () {
    const request = OpenThumbnailReadRequest(
      contentUri: 'content://media/external/images/media/1',
      size: ThumbnailSize(width: 256, height: 128),
    );

    expect(request.toJson(), {
      'contentUri': 'content://media/external/images/media/1',
      'size': {'width': 256, 'height': 128},
    });
  });
}
