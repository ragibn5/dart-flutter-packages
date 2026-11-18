import 'package:content_io_android/src/utils/json_decoder.dart';
import 'package:flutter_test/flutter_test.dart';

/// Decodes a test object; top-level, so it can be sent to another isolate.
String _decodeName(Map<String, dynamic> json) => json['name'] as String;

void main() {
  group('decodeJsonObject', () {
    test('decodeJsonObjectShouldReturnDecodedObjectIfJsonIsValid', () {
      expect(decodeJsonObject('{"name": "a"}', _decodeName), 'a');
    });

    test('decodeJsonObjectShouldThrowFormatExceptionIfJsonIsInvalid', () {
      expect(() => decodeJsonObject('{', _decodeName), throwsFormatException);
    });
  });

  group('decodeJsonList', () {
    test('decodeJsonListShouldReturnObjectsInOrderIfJsonIsValid', () {
      expect(decodeJsonList('[{"name": "a"}, {"name": "b"}]', _decodeName), [
        'a',
        'b',
      ]);
    });

    test('decodeJsonListShouldThrowFormatExceptionIfJsonIsInvalid', () {
      expect(() => decodeJsonList('[', _decodeName), throwsFormatException);
    });
  });

  group('decodeJsonListInBackground', () {
    test(
      'decodeJsonListInBackgroundShouldReturnObjectsInOrderIfJsonIsValid',
      () async {
        expect(
          await decodeJsonListInBackground(
            '[{"name": "a"}, {"name": "b"}]',
            _decodeName,
          ),
          ['a', 'b'],
        );
      },
    );

    test(
      'decodeJsonListInBackgroundShouldThrowFormatExceptionIfJsonIsInvalid',
      () {
        expect(
          decodeJsonListInBackground('[', _decodeName),
          throwsFormatException,
        );
      },
    );
  });
}
