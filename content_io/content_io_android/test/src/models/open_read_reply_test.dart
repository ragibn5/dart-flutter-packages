import 'package:content_io_android/src/models/open_read_reply.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OpenReadReply', () {
    test('fromJsonShouldReturnDescriptorReplyIfKindIsDescriptor', () {
      final reply = OpenReadReply.fromJson(const {
        'kind': 'descriptor',
        'fd': 42,
        'offset': 512,
        'sizeInBytes': 2048,
        'isSeekable': true,
      });

      expect(
        reply,
        const DescriptorReply(
          fd: 42,
          offset: 512,
          sizeInBytes: 2048,
          isSeekable: true,
        ),
      );
    });

    test('fromJsonShouldReturnChannelReplyIfKindIsChannel', () {
      final reply = OpenReadReply.fromJson(const {
        'kind': 'channel',
        'sessionId': 'session-1',
        'sizeInBytes': null,
        'isSeekable': false,
      });

      expect(
        reply,
        const ChannelReply(
          sessionId: 'session-1',
          sizeInBytes: null,
          isSeekable: false,
        ),
      );
    });

    test('fromJsonShouldThrowFormatExceptionIfKindIsNotKnown', () {
      expect(
        () => OpenReadReply.fromJson(const {'kind': 'socket'}),
        throwsFormatException,
      );
    });
  });

  group('DescriptorReply', () {
    test('fromJsonShouldUseZeroOffsetIfOffsetIsMissing', () {
      final reply = DescriptorReply.fromJson(const {
        'fd': 42,
        'sizeInBytes': 2048,
        'isSeekable': true,
      });

      expect(reply.offset, 0);
    });
  });
}
