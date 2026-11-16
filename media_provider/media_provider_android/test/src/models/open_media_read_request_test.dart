import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/src/models/open_media_read_request.dart';

import '../../helpers/fixtures.dart';

void main() {
  test('fromItemShouldUseFilePathIfItemHasFile', () {
    expect(
      OpenMediaReadRequest.fromItem(photoItem),
      const OpenMediaReadRequest(
        contentUri: 'content://media/external/images/media/1',
        filePath: '/storage/emulated/0/DCIM/Camera/IMG_0001.jpg',
      ),
    );
  });

  test('fromItemShouldUseNoFilePathIfItemHasNoFile', () {
    expect(
      OpenMediaReadRequest.fromItem(videoItemWithoutFile).filePath,
      isNull,
    );
  });

  test('toJsonShouldLeaveOutFilePath', () {
    const request = OpenMediaReadRequest(
      contentUri: 'content://media/external/images/media/1',
      filePath: '/storage/emulated/0/DCIM/Camera/IMG_0001.jpg',
    );

    expect(request.toJson(), {
      'contentUri': 'content://media/external/images/media/1',
    });
  });
}
