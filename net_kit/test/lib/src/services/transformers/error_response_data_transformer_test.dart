import 'package:net_kit/src/enums/parse_target_type.dart';
import 'package:net_kit/src/models/net_client_exception.dart';
import 'package:net_kit/src/services/codec/request_data_codec.dart';
import 'package:net_kit/src/services/transformers/error_response_data_transformer.dart';
import 'package:test/test.dart';

class IdentityErrorResponseDataDecoder
    implements ErrorResponseDataDecoder<dynamic> {
  const IdentityErrorResponseDataDecoder();

  @override
  dynamic decodeErrorData(dynamic raw) => raw;
}

class ThrowingErrorResponseDataDecoder
    implements ErrorResponseDataDecoder<String> {
  const ThrowingErrorResponseDataDecoder(this.throwable);

  final Object throwable;

  @override
  // ignore: only_throw_errors
  String decodeErrorData(dynamic raw) => throw throwable;
}

void main() {
  late ErrorResponseDataTransformer errorResponseDataTransformer;

  setUp(() {
    errorResponseDataTransformer = const DefaultErrorResponseDataTransformer();
  });

  test('If decoder does not throw, returns Result.success() with decoded data',
      () {
    final result = errorResponseDataTransformer.transform(
      'data',
      const IdentityErrorResponseDataDecoder(),
    );
    expect(result.isSuccess, true);
    expect(result.resultOrNull, 'data');
  });

  test('If decoder throws, returns Result.error() with ParseException()', () {
    final throwable = Exception('invalid-error-decodable-data');
    final result = errorResponseDataTransformer.transform(
      'decodable-error-data',
      ThrowingErrorResponseDataDecoder(throwable),
    );
    expect(result.isError, true);
    expect(
      result.errorOrNull,
      isA<ParseException>()
          .having(
            (p) => p.targetType,
            'targetType',
            ParseTargetType.ERROR_DECODE,
          )
          .having(
            (p) => p.data,
            'data',
            'decodable-error-data',
          )
          .having((p) => p.cause, 'cause', throwable)
          .having((p) => p.stackTrace, 'stackTrace', isNotNull),
    );
  });
}
