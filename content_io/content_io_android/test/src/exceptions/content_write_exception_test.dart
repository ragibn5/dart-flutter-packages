import 'package:content_io_android/src/exceptions/content_write_exception.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContentWriteException', () {
    const exceptions = <ContentWriteException, String>{
      InvalidWriteRequestError('m'): 'InvalidWriteRequestError',
      WriteSessionNotFoundException('m', sessionId: 's1'):
          'WriteSessionNotFoundException',
      NotEnoughSpaceException('m'): 'NotEnoughSpaceException',
      WriteException('m'): 'WriteException',
    };

    for (final MapEntry(key: exception, value: name) in exceptions.entries) {
      test('toStringShouldName$name', () {
        expect(exception.toString(), '$name: m');
      });
    }

    test('toStringShouldSayNoMessageIfMessageIsNull', () {
      expect(
        const WriteException(null).toString(),
        'WriteException: no message',
      );
    });
  });

  group('ContentWriteExceptionMapper', () {
    const mapper = ContentWriteExceptionMapper();

    test(
      'mapShouldReturnSessionNotFoundWithSessionIdIfCodeIsSessionNotFound',
      () {
        expect(
          mapper.map(
            PlatformException(
              code: 'session_not_found',
              message: 'closed',
              details: {'sessionId': 's1'},
            ),
          ),
          isA<WriteSessionNotFoundException>()
              .having((e) => e.message, 'message', 'closed')
              .having((e) => e.sessionId, 'sessionId', 's1'),
        );
      },
    );

    test('mapShouldUseEmptySessionIdIfDetailsAreMissing', () {
      expect(
        mapper.map(PlatformException(code: 'session_not_found')),
        isA<WriteSessionNotFoundException>().having(
          (e) => e.sessionId,
          'sessionId',
          '',
        ),
      );
    });

    final codes = <String, TypeMatcher<ContentWriteException>>{
      'invalid_request': isA<InvalidWriteRequestError>(),
      'not_enough_space': isA<NotEnoughSpaceException>(),
      'write_error': isA<WriteException>(),
    };

    for (final MapEntry(key: code, value: matcher) in codes.entries) {
      test('mapShouldReturnItsExceptionIfCodeIs_$code', () {
        expect(
          mapper.map(PlatformException(code: code, message: 'm')),
          matcher.having((e) => e.message, 'message', 'm'),
        );
      });
    }

    test('mapShouldReturnThePlatformExceptionIfCodeIsUnknown', () {
      final exception = PlatformException(code: 'unknown');

      expect(mapper.map(exception), same(exception));
    });
  });
}
