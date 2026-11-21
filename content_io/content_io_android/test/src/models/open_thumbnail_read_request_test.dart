import 'package:content_io_android/src/models/open_thumbnail_read_request.dart';
import 'package:content_io_android/src/models/thumbnail_size.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('toJsonShouldEncodeSizeAsMap', () {
    const request = OpenThumbnailReadRequest(
      uri: 'content://media/external/images/media/1',
      size: ThumbnailSize(width: 256, height: 128),
    );

    expect(request.toJson(), {
      'uri': 'content://media/external/images/media/1',
      'size': {'width': 256, 'height': 128},
      'scaleDownToSize': true,
      'rotateUpright': true,
    });
  });

  test('toJsonShouldEncodeFitOptionsAsGiven', () {
    const request = OpenThumbnailReadRequest(
      uri: 'content://media/external/images/media/1',
      size: ThumbnailSize(width: 256, height: 128),
      scaleDownToSize: false,
      rotateUpright: false,
    );

    expect(request.toJson(), containsPair('scaleDownToSize', false));
    expect(request.toJson(), containsPair('rotateUpright', false));
  });

  test('fromJsonShouldDecodeFitOptions', () {
    final request = OpenThumbnailReadRequest.fromJson(const {
      'uri': 'content://media/external/images/media/1',
      'size': {'width': 256, 'height': 128},
      'scaleDownToSize': false,
      'rotateUpright': false,
    });

    expect(
      request,
      const OpenThumbnailReadRequest(
        uri: 'content://media/external/images/media/1',
        size: ThumbnailSize(width: 256, height: 128),
        scaleDownToSize: false,
        rotateUpright: false,
      ),
    );
  });
}
