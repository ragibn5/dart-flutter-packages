import 'package:document_tree_android/src/exceptions/document_exceptions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DocumentException', () {
    const exceptions = <Exception, String>{
      TreeAccessLostException('m'): 'TreeAccessLostException',
      TreeUnavailableException('m'): 'TreeUnavailableException',
      InvalidQueryError('m'): 'InvalidQueryError',
      DocumentNotFoundException('m'): 'DocumentNotFoundException',
      InvalidWriteError('m'): 'InvalidWriteError',
      TreeNotWritableException('m'): 'TreeNotWritableException',
      DocumentAlreadyExistsException('m'): 'DocumentAlreadyExistsException',
      SourceNotFoundException('m'): 'SourceNotFoundException',
      SourcePermissionDeniedException('m'): 'SourcePermissionDeniedException',
      NotEnoughSpaceException('m'): 'NotEnoughSpaceException',
      DocumentWriteFailedException('m'): 'DocumentWriteFailedException',
    };

    for (final MapEntry(key: exception, value: name) in exceptions.entries) {
      test('toStringShouldName$name', () {
        expect(exception.toString(), '$name: m');
      });
    }

    test('toStringShouldSayNoMessageIfMessageIsNull', () {
      expect(
        const NotEnoughSpaceException(null).toString(),
        'NotEnoughSpaceException: no message',
      );
    });
  });

  group('DocumentQueryExceptionMapper', () {
    const mapper = DocumentQueryExceptionMapper();

    final codes = <String, TypeMatcher<DocumentQueryException>>{
      'invalid_request': isA<InvalidQueryError>(),
      'access_lost': isA<TreeAccessLostException>(),
      'tree_unavailable': isA<TreeUnavailableException>(),
      'not_found': isA<DocumentNotFoundException>(),
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

  group('DocumentWriteExceptionMapper', () {
    const mapper = DocumentWriteExceptionMapper();

    final codes = <String, TypeMatcher<DocumentWriteException>>{
      'invalid_request': isA<InvalidWriteError>(),
      'access_lost': isA<TreeAccessLostException>(),
      'tree_unavailable': isA<TreeUnavailableException>(),
      'not_writable': isA<TreeNotWritableException>(),
      'already_exists': isA<DocumentAlreadyExistsException>(),
      'source_not_found': isA<SourceNotFoundException>(),
      'source_permission_denied': isA<SourcePermissionDeniedException>(),
      'not_enough_space': isA<NotEnoughSpaceException>(),
      'write_error': isA<DocumentWriteFailedException>(),
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
