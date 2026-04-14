import 'package:net_kit/src/enums/parse_target_type.dart';
import 'package:net_kit/src/models/net_kit_exception.dart';
import 'package:net_kit/src/services/codec/net_kit_response_decoder.dart';
import 'package:test/test.dart';

void main() {
  late NetKitResponseDecoder sut;

  setUp(() {
    sut = const DefaultNetKitResponseDecoder(ParseTargetType.RESPONSE_DECODE);
  });

  test('If data is null, returns Result.success() with null data', () {
    final result = sut.decode(null, (data) => data);
    expect(result.isSuccess, true);
    expect(result.resultOrNull, null);
  });

  test(
    'If decoder does not throw, returns Result.success() with decoded data',
    () {
      final result = sut.decode('data', (data) => data);
      expect(result.isSuccess, true);
      expect(result.resultOrNull, 'data');
    },
  );

  test(
    'If decoder throws, returns Result.error() with ParseException()',
    () {
      final throwable = Exception('invalid-decodable-data');
      final result = sut.decode('decodable-data', (data) => throw throwable);
      expect(result.isError, true);
      expect(
        result.errorOrNull,
        isA<ParseException>()
            .having(
              (p) => p.targetType,
              'targetType',
              ParseTargetType.RESPONSE_DECODE,
            )
            .having(
              (p) => p.data,
              'data',
              'decodable-data',
            )
            .having((p) => p.cause, 'cause', throwable)
            .having((p) => p.stackTrace, 'stackTrace', isNotNull),
      );
    },
  );
}
