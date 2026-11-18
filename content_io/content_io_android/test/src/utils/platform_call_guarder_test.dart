import 'package:content_io_android/src/exceptions/platform_exception_mapper.dart';
import 'package:content_io_android/src/utils/platform_call_guarder.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _MappedException implements Exception {
  final PlatformException source;

  const _MappedException(this.source);
}

class _FakeMapper implements PlatformExceptionMapper {
  const _FakeMapper();

  @override
  Exception map(PlatformException e) => _MappedException(e);
}

void main() {
  test('guardPlatformCallShouldReturnResultIfCallSucceeds', () async {
    expect(await guardPlatformCall(const _FakeMapper(), () async => 42), 42);
  });

  test(
    'guardPlatformCallShouldThrowMappedExceptionIfCallThrowsPlatformException',
    () {
      final exception = PlatformException(code: 'invalid_request');

      expect(
        guardPlatformCall<void>(const _FakeMapper(), () => throw exception),
        throwsA(
          isA<_MappedException>().having(
            (e) => e.source,
            'source',
            same(exception),
          ),
        ),
      );
    },
  );

  test(
    'guardPlatformCallShouldRethrowUnchangedIfCallThrowsAnotherException',
    () {
      final error = StateError('not a platform failure');

      expect(
        guardPlatformCall<void>(const _FakeMapper(), () => throw error),
        throwsA(same(error)),
      );
    },
  );
}
