import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/src/models/share_media_request.dart';

import '../../helpers/fixtures.dart';

void main() {
  test('shouldThrowAssertionErrorIfContentUrisIsEmpty', () {
    expect(
      () => ShareMediaRequest(contentUris: List.empty()),
      throwsAssertionError,
    );
  });

  test('fromItemsShouldUseItemUrisInOrderAndGivenChooserTitle', () {
    expect(
      ShareMediaRequest.fromItems(const [
        photoItem,
        videoItemWithoutFile,
      ], chooserTitle: 'Share'),
      ShareMediaRequest(
        contentUris: const [
          'content://media/external/images/media/1',
          'content://media/external/video/media/2',
        ],
        chooserTitle: 'Share',
      ),
    );
  });
}
