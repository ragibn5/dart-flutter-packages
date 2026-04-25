import 'package:net_kit/src/enums/parse_target_type.dart';
import 'package:net_kit/src/models/net_client_exception.dart';
import 'package:net_kit/src/services/codec/request_data_codec.dart';
import 'package:net_kit/src/services/transformers/request_data_transformer.dart';
import 'package:test/test.dart';

class IdentityRequestDataEncoder implements RequestDataEncoder<dynamic> {
  const IdentityRequestDataEncoder();

  @override
  dynamic encodeRequestData(dynamic data) => data;
}

class ThrowingRequestDataEncoder implements RequestDataEncoder<String> {
  const ThrowingRequestDataEncoder(this.throwable);

  final Object throwable;

  @override
  // ignore: only_throw_errors
  dynamic encodeRequestData(String data) => throw throwable;
}

void main() {
  late RequestDataTransformer requestDataTransformer;

  setUp(() {
    requestDataTransformer = const DefaultRequestDataTransformer();
  });

  test('If data is null, returns Result.success() with null data', () {
    final result = requestDataTransformer.transform(
        null, const IdentityRequestDataEncoder());
    expect(result.isSuccess, true);
    expect(result.resultOrNull, null);
  });

  test(
    'If encoder does not throw, returns Result.success() with encoded data',
    () {
      final result = requestDataTransformer.transform(
        'data',
        const IdentityRequestDataEncoder(),
      );
      expect(result.isSuccess, true);
      expect(result.resultOrNull, 'data');
    },
  );

  test(
    'If encoder throws, returns Result.error() with ParseException()',
    () {
      final throwable = Exception('invalid-encodable-data');
      final result = requestDataTransformer.transform(
        'encodable-data',
        ThrowingRequestDataEncoder(throwable),
      );
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
