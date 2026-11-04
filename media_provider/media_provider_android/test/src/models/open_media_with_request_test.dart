import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/src/models/open_media_with_request.dart';

import '../../helpers/fixtures.dart';

void main() {
  test('fromItemShouldUseItemUriAndGivenChooserTitle', () {
    expect(
      OpenMediaWithRequest.fromItem(photoItem, chooserTitle: 'Open with'),
      const OpenMediaWithRequest(
        contentUri: 'content://media/external/images/media/1',
        chooserTitle: 'Open with',
      ),
    );
  });
}
