import 'package:document_tree_android/src/exceptions/tree_request_exception.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TreeRequestException', () {
    test('toStringShouldNameInvalidTreeRequestError', () {
      expect(
        const InvalidTreeRequestError('bad').toString(),
        'InvalidTreeRequestError: bad',
      );
    });

    test('toStringShouldSayNoMessageIfMessageIsNull', () {
      expect(
        const InvalidTreeRequestError(null).toString(),
        'InvalidTreeRequestError: no message',
      );
    });
  });

  group('TreeRequestExceptionMapper', () {
    const mapper = TreeRequestExceptionMapper();

    test('mapShouldReturnInvalidTreeRequestErrorIfCodeIsInvalidRequest', () {
      final mapped = mapper.map(
        PlatformException(code: 'invalid_request', message: 'bad'),
      );

      expect(
        mapped,
        isA<InvalidTreeRequestError>().having(
          (e) => e.message,
          'message',
          'bad',
        ),
      );
    });

    test('mapShouldReturnThePlatformExceptionIfCodeIsUnknown', () {
      final exception = PlatformException(code: 'unknown');

      expect(mapper.map(exception), same(exception));
    });
  });
}
