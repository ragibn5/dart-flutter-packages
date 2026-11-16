import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/src/exceptions/media_read_open_exception.dart';

void main() {
  group('MediaReadOpenException', () {
    test('toStringShouldNameInvalidOpenRequestError', () {
      expect(
        const InvalidOpenRequestError('bad').toString(),
        'InvalidOpenRequestError: bad',
      );
    });

    test('toStringShouldNameMediaNotFoundException', () {
      expect(
        const MediaNotFoundException(
          'gone',
          uri: null,
          partialAccess: false,
        ).toString(),
        'MediaNotFoundException: gone',
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

  group('MediaReadOpenExceptionMapper', () {
    const mapper = MediaReadOpenExceptionMapper();

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

    test('mapShouldReturnMediaNotFoundExceptionIfCodeIsNotFound', () {
      final mapped = mapper.map(
        PlatformException(
          code: 'not_found',
          message: 'gone',
          details: {
            'uri': 'content://media/external/images/media/1',
            'partialAccess': true,
          },
        ),
      );

      expect(
        mapped,
        isA<MediaNotFoundException>()
            .having((e) => e.message, 'message', 'gone')
            .having(
              (e) => e.uri,
              'uri',
              'content://media/external/images/media/1',
            )
            .having((e) => e.partialAccess, 'partialAccess', isTrue),
      );
    });

    test('mapShouldUseNoUriAndNoPartialAccessIfDetailsAreMissing', () {
      final mapped = mapper.map(PlatformException(code: 'not_found'));

      expect(
        mapped,
        isA<MediaNotFoundException>()
            .having((e) => e.uri, 'uri', isNull)
            .having((e) => e.partialAccess, 'partialAccess', isFalse),
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
