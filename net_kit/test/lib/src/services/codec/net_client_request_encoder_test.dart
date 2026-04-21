import 'package:net_kit/src/enums/parse_target_type.dart';
import 'package:net_kit/src/models/net_client_exception.dart';
import 'package:net_kit/src/services/codec/net_client_request_encoder.dart';
import 'package:test/test.dart';

void main() {
  late NetClientRequestEncoder sut;

  setUp(() {
    sut = const DefaultNetClientRequestEncoder();
  });

  test('If data is null, returns Result.success() with null data', () {
    final result = sut.encode(null, (data) => data);
    expect(result.isSuccess, true);
    expect(result.resultOrNull, null);
  });

  test(
    'If encoder does not throw, returns Result.success() with encoded data',
    () {
      final result = sut.encode('data', (data) => data);
      expect(result.isSuccess, true);
      expect(result.resultOrNull, 'data');
    },
  );

  test(
    'If encoder throws, returns Result.error() with ParseException()',
    () {
      final throwable = Exception('invalid-encodable-data');
      final result = sut.encode('encodable-data', (data) => throw throwable);
      expect(result.isError, true);
      expect(
        result.errorOrNull,
        isA<ParseException>()
            .having(
              (p) => p.targetType,
              'targetType',
              ParseTargetType.REQUEST_ENCODE,
            )
            .having(
              (p) => p.data,
              'data',
              'encodable-data',
            )
            .having((p) => p.cause, 'cause', throwable)
            .having((p) => p.stackTrace, 'stackTrace', isNotNull),
      );
    },
  );
}
