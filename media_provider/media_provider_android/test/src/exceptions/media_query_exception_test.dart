import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_provider_android/src/exceptions/media_query_exception.dart';

void main() {
  group('MediaQueryException', () {
    test('toStringShouldNameInvalidQueryError', () {
      expect(
        const InvalidQueryError('bad query').toString(),
        'InvalidQueryError: bad query',
      );
    });

    test('toStringShouldSayNoMessageIfMessageIsNull', () {
      expect(
        const InvalidQueryError(null).toString(),
        'InvalidQueryError: no message',
      );
    });
  });

  group('MediaQueryExceptionMapper', () {
    const mapper = MediaQueryExceptionMapper();

    test('mapShouldReturnInvalidQueryErrorIfCodeIsInvalidRequest', () {
      final mapped = mapper.map(
        PlatformException(code: 'invalid_request', message: 'bad query'),
      );

      expect(
        mapped,
        isA<InvalidQueryError>().having(
          (e) => e.message,
          'message',
          'bad query',
        ),
      );
    });

    test('mapShouldReturnSameExceptionIfCodeIsNotKnown', () {
      final exception = PlatformException(code: 'unexpected');

      expect(mapper.map(exception), same(exception));
    });
  });
}
