import 'package:content_io_android/src/exceptions/content_read_exception.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContentReadException', () {
    test('toStringShouldNameInvalidReadRequestError', () {
      expect(
        const InvalidReadRequestError('bad').toString(),
        'InvalidReadRequestError: bad',
      );
    });

    test('toStringShouldNameSessionNotFoundException', () {
      expect(
        const SessionNotFoundException('closed', sessionId: 's1').toString(),
        'SessionNotFoundException: closed',
      );
    });

    test('toStringShouldNameReadException', () {
      expect(const ReadException('io').toString(), 'ReadException: io');
    });

    test('toStringShouldSayNoMessageIfMessageIsNull', () {
      expect(const ReadException(null).toString(), 'ReadException: no message');
    });
  });

  group('ContentReadExceptionMapper', () {
    const mapper = ContentReadExceptionMapper();

    test('mapShouldReturnSessionNotFoundExceptionIfCodeIsSessionNotFound', () {
      final mapped = mapper.map(
        PlatformException(
          code: 'session_not_found',
          message: 'closed',
          details: {'sessionId': 's1'},
        ),
      );

      expect(
        mapped,
        isA<SessionNotFoundException>()
            .having((e) => e.message, 'message', 'closed')
            .having((e) => e.sessionId, 'sessionId', 's1'),
      );
    });

    test('mapShouldUseEmptySessionIdIfDetailsAreMissing', () {
      final mapped = mapper.map(PlatformException(code: 'session_not_found'));

      expect(
        mapped,
        isA<SessionNotFoundException>().having(
          (e) => e.sessionId,
          'sessionId',
          isEmpty,
        ),
      );
    });

    test('mapShouldReturnInvalidReadRequestErrorIfCodeIsInvalidRequest', () {
      final mapped = mapper.map(
        PlatformException(code: 'invalid_request', message: 'bad'),
      );

      expect(
        mapped,
        isA<InvalidReadRequestError>().having(
          (e) => e.message,
          'message',
          'bad',
        ),
      );
    });

    test('mapShouldReturnReadExceptionIfCodeIsReadError', () {
      final mapped = mapper.map(
        PlatformException(code: 'read_error', message: 'io'),
      );

      expect(
        mapped,
        isA<ReadException>().having((e) => e.message, 'message', 'io'),
      );
    });

    test('mapShouldReturnSameExceptionIfCodeIsNotKnown', () {
      final exception = PlatformException(code: 'unexpected');

      expect(mapper.map(exception), same(exception));
    });
  });
}
