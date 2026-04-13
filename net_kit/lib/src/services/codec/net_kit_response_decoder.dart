import 'package:net_kit/src/enums/parse_target_type.dart';
import 'package:net_kit/src/models/net_kit_exception.dart';
import 'package:net_kit/src/models/result.dart';
import 'package:net_kit/src/services/codec/net_kit_decoder.dart';

abstract interface class NetKitResponseDecoder
    implements NetKitDecoder<dynamic> {}

class DefaultNetKitResponseDecoder implements NetKitResponseDecoder {
  final ParseTargetType targetType;

  const DefaultNetKitResponseDecoder(this.targetType);

  @override
  DecodeResult<D> decode<D>(dynamic data, D Function(dynamic) decoder) {
    try {
      return Result.success(decoder(data));
    } catch (e, st) {
      return Result.error(
        ParseException(
          targetType: targetType,
          data: data,
          cause: e,
          stackTrace: st,
        ),
      );
    }
  }
}
