import 'package:content_io_android/src/exceptions/content_hash_exception_mapper.dart';
import 'package:content_io_android/src/exceptions/content_open_exception.dart';
import 'package:content_io_android/src/exceptions/content_read_exception.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const mapper = ContentHashExceptionMapper();

  test('mapShouldReturnReadExceptionIfCodeIsReadError', () {
    expect(
      mapper.map(PlatformException(code: 'read_error', message: 'io')),
      isA<ReadException>(),
    );
  });

  for (final (code, type) in [
    ('not_found', ContentNotFoundException),
    ('permission_denied', PermissionDeniedException),
    ('invalid_request', InvalidOpenRequestError),
    ('unsupported_operation', UnsupportedOperationException),
  ]) {
    test('mapShouldReturn${type}IfCodeIs_$code', () {
      expect(mapper.map(PlatformException(code: code)).runtimeType, type);
    });
  }

  test('mapShouldReturnThePlatformExceptionIfCodeIsUnknown', () {
    final exception = PlatformException(code: 'unexpected_error');

    expect(mapper.map(exception), same(exception));
  });
}
