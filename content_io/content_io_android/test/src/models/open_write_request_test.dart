import 'package:content_io_android/src/models/open_write_request.dart';
import 'package:content_io_android/src/models/write_mode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('modeShouldBeTruncateIfNotGiven', () {
    expect(const OpenWriteRequest(uri: 'content://a').mode, WriteMode.truncate);
  });

  test('toJsonShouldEncodeModeByItsStoredName', () {
    const request = OpenWriteRequest(
      uri: 'content://a',
      mode: WriteMode.append,
    );

    expect(request.toJson(), {'uri': 'content://a', 'mode': 'append'});
  });
}
