import 'package:content_io_android/src/models/open_write_reply.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromJsonShouldReturnDescriptorReplyIfKindIsDescriptor', () {
    expect(
      OpenWriteReply.fromJson(const {'kind': 'descriptor', 'fd': 42}),
      const WriteDescriptorReply(fd: 42),
    );
  });

  test('fromJsonShouldReturnChannelReplyIfKindIsChannel', () {
    expect(
      OpenWriteReply.fromJson(const {
        'kind': 'channel',
        'sessionId': 'session-1',
      }),
      const WriteChannelReply(sessionId: 'session-1'),
    );
  });

  test('fromJsonShouldThrowFormatExceptionIfKindIsUnknown', () {
    expect(
      () => OpenWriteReply.fromJson(const {'kind': 'pipe'}),
      throwsFormatException,
    );
  });
}
