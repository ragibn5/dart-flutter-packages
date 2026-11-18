import 'package:content_io_android/src/models/open_read_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('toJsonShouldLeaveOutFilePath', () {
    const request = OpenReadRequest(
      uri: 'content://media/external/images/media/1',
      filePath: '/storage/emulated/0/DCIM/Camera/IMG_0001.jpg',
    );

    expect(request.toJson(), {
      'uri': 'content://media/external/images/media/1',
    });
  });
}
