import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/src/models/media_item.dart';

import '../../helpers/fixtures.dart';

void main() {
  test('fromJsonShouldDecodeEveryFieldIfJsonIsComplete', () {
    expect(MediaItem.fromJson(photoItemJson), photoItem);
  });

  test('fromJsonShouldDecodeNullsIfOptionalFieldsAreNull', () {
    final item = MediaItem.fromJson(const {
      'type': 'VIDEO',
      'uri': 'content://media/external/video/media/2',
      'id': '2',
      'fileLocation': null,
      'name': null,
      'mimeType': null,
      'sizeInBytes': null,
      'dateAddedInMillis': null,
      'dateModifiedInMillis': null,
      'dateTakenInMillis': null,
      'ownerPackageName': null,
      'isPending': null,
      'isTrashed': null,
      'isFavorite': null,
      'isDownloaded': null,
    });

    expect(item, videoItemWithoutFile);
  });

  test('toJsonShouldEncodeFileLocationAsMap', () {
    expect(photoItem.toJson(), photoItemJson);
  });
}
