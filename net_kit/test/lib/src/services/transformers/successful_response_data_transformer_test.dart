import 'package:net_kit/src/enums/parse_target_type.dart';
import 'package:net_kit/src/models/net_client_exception.dart';
import 'package:net_kit/src/services/codec/request_data_codec.dart';
import 'package:net_kit/src/services/transformers/successful_response_data_transformer.dart';
import 'package:test/test.dart';

class IdentityResponseDataDecoder implements ResponseDataDecoder<dynamic> {
  const IdentityResponseDataDecoder();

  @override
  dynamic decodeData(dynamic raw) => raw;
}

class ThrowingResponseDataDecoder implements ResponseDataDecoder<String> {
  const ThrowingResponseDataDecoder(this.throwable);

  final Object throwable;

  @override
  // ignore: only_throw_errors
  String decodeData(dynamic raw) => throw throwable;
}

void main() {
  late SuccessfulResponseDataTransformer successfulResponseDataTransformer;

  setUp(() {
    successfulResponseDataTransformer =
        const DefaultSuccessfulResponseDataTransformer();
  });

  test('If data is null, returns Result.success() with null data', () {
    final result = successfulResponseDataTransformer.transform(
      null,
      const IdentityResponseDataDecoder(),
    );
    expect(result.isSuccess, true);
    expect(result.resultOrNull, null);
  });

  test(
    'If decoder does not throw, returns Result.success() with decoded data',
    () {
      final result = successfulResponseDataTransformer.transform(
        'data',
        const IdentityResponseDataDecoder(),
      );
      expect(result.isSuccess, true);
      expect(result.resultOrNull, 'data');
    },
  );

  test(
    'If decoder throws, returns Result.error() with ParseException()',
    () {
      final throwable = Exception('invalid-decodable-data');
      final result = successfulResponseDataTransformer.transform(
        'decodable-data',
        ThrowingResponseDataDecoder(throwable),
      );
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
