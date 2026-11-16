import 'package:document_tree_android/src/exceptions/tree_pick_exception.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TreePickException', () {
    const exceptions = <TreePickException, String>{
      InvalidPickRequestError('m'): 'InvalidPickRequestError',
      NoActivityException('m'): 'NoActivityException',
      PickerAlreadyOpenException('m'): 'PickerAlreadyOpenException',
      PickerUnavailableException('m'): 'PickerUnavailableException',
    };

    for (final MapEntry(key: exception, value: name) in exceptions.entries) {
      test('toStringShouldName$name', () {
        expect(exception.toString(), '$name: m');
      });
    }

    test('toStringShouldSayNoMessageIfMessageIsNull', () {
      expect(
        const NoActivityException(null).toString(),
        'NoActivityException: no message',
      );
    });
  });

  group('TreePickExceptionMapper', () {
    const mapper = TreePickExceptionMapper();

    final codes = <String, TypeMatcher<TreePickException>>{
      'invalid_request': isA<InvalidPickRequestError>(),
      'no_activity': isA<NoActivityException>(),
      'picker_already_open': isA<PickerAlreadyOpenException>(),
      'picker_unavailable': isA<PickerUnavailableException>(),
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
