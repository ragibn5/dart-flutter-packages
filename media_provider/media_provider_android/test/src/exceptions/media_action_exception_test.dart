import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/src/exceptions/media_action_exception.dart';

void main() {
  group('MediaActionException', () {
    test('toStringShouldNameInvalidActionRequestError', () {
      expect(
        const InvalidActionRequestError('bad').toString(),
        'InvalidActionRequestError: bad',
      );
    });

    test('toStringShouldNameActionNotPermittedException', () {
      expect(
        const ActionNotPermittedException('denied').toString(),
        'ActionNotPermittedException: denied',
      );
    });

    test('toStringShouldNameNoActivityException', () {
      expect(
        const NoActivityException('detached').toString(),
        'NoActivityException: detached',
      );
    });

    test('toStringShouldSayNoMessageIfMessageIsNull', () {
      expect(
        const NoActivityException(null).toString(),
        'NoActivityException: no message',
      );
    });
  });

  group('MediaActionExceptionMapper', () {
    const mapper = MediaActionExceptionMapper();

    test('mapShouldReturnInvalidActionRequestErrorIfCodeIsInvalidRequest', () {
      final mapped = mapper.map(
        PlatformException(code: 'invalid_request', message: 'bad'),
      );

      expect(
        mapped,
        isA<InvalidActionRequestError>().having(
          (e) => e.message,
          'message',
          'bad',
        ),
      );
    });

    test(
      'mapShouldReturnActionNotPermittedExceptionIfCodeIsPermissionDenied',
      () {
        final mapped = mapper.map(
          PlatformException(code: 'permission_denied', message: 'denied'),
        );

        expect(
          mapped,
          isA<ActionNotPermittedException>().having(
            (e) => e.message,
            'message',
            'denied',
          ),
        );
      },
    );

    test('mapShouldReturnNoActivityExceptionIfCodeIsNoActivity', () {
      final mapped = mapper.map(
        PlatformException(code: 'no_activity', message: 'detached'),
      );

      expect(
        mapped,
        isA<NoActivityException>().having(
          (e) => e.message,
          'message',
          'detached',
        ),
      );
    });

    test('mapShouldReturnSameExceptionIfCodeIsNotKnown', () {
      final exception = PlatformException(code: 'unexpected');

      expect(mapper.map(exception), same(exception));
    });
  });
}
