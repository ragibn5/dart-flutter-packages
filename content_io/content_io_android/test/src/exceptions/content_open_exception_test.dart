import 'package:content_io_android/src/exceptions/content_open_exception.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ContentOpenException', () {
    test('toStringShouldNameInvalidOpenRequestError', () {
      expect(
        const InvalidOpenRequestError('bad').toString(),
        'InvalidOpenRequestError: bad',
      );
    });

    test('toStringShouldNameContentNotFoundException', () {
      expect(
        const ContentNotFoundException('gone', uri: null).toString(),
        'ContentNotFoundException: gone',
      );
    });

    test('toStringShouldNamePermissionDeniedException', () {
      expect(
        const PermissionDeniedException('denied').toString(),
        'PermissionDeniedException: denied',
      );
    });

    test('toStringShouldNameUnsupportedOperationException', () {
      expect(
        const UnsupportedOperationException('no').toString(),
        'UnsupportedOperationException: no',
      );
    });

    test('toStringShouldSayNoMessageIfMessageIsNull', () {
      expect(
        const PermissionDeniedException(null).toString(),
        'PermissionDeniedException: no message',
      );
    });
  });

  group('ContentOpenExceptionMapper', () {
    const mapper = ContentOpenExceptionMapper();

    test(
      'mapShouldReturnPermissionDeniedExceptionIfCodeIsPermissionDenied',
      () {
        final mapped = mapper.map(
          PlatformException(code: 'permission_denied', message: 'denied'),
        );

        expect(
          mapped,
          isA<PermissionDeniedException>().having(
            (e) => e.message,
            'message',
            'denied',
          ),
        );
      },
    );

    test('mapShouldReturnContentNotFoundExceptionIfCodeIsNotFound', () {
      final mapped = mapper.map(
        PlatformException(
          code: 'not_found',
          message: 'gone',
          details: {'uri': 'content://media/external/images/media/1'},
        ),
      );

      expect(
        mapped,
        isA<ContentNotFoundException>()
            .having((e) => e.message, 'message', 'gone')
            .having(
              (e) => e.uri,
              'uri',
              'content://media/external/images/media/1',
            ),
      );
    });

    test('mapShouldUseNoUriIfDetailsAreMissing', () {
      final mapped = mapper.map(PlatformException(code: 'not_found'));

      expect(
        mapped,
        isA<ContentNotFoundException>().having((e) => e.uri, 'uri', isNull),
      );
    });

    test('mapShouldReturnInvalidOpenRequestErrorIfCodeIsInvalidRequest', () {
      final mapped = mapper.map(
        PlatformException(code: 'invalid_request', message: 'bad'),
      );

      expect(
        mapped,
        isA<InvalidOpenRequestError>().having(
          (e) => e.message,
          'message',
          'bad',
        ),
      );
    });

    test('mapShouldReturnUnsupportedOperationExceptionIfCodeIsUnsupported', () {
      final mapped = mapper.map(
        PlatformException(code: 'unsupported_operation', message: 'no'),
      );

      expect(
        mapped,
        isA<UnsupportedOperationException>().having(
          (e) => e.message,
          'message',
          'no',
        ),
      );
    });

    test('mapShouldReturnSameExceptionIfCodeIsNotKnown', () {
      final exception = PlatformException(code: 'unexpected');

      expect(mapper.map(exception), same(exception));
    });
  });
}
