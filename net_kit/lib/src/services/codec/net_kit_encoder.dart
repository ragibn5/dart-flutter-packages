import 'package:net_kit/src/models/net_kit_exception.dart';
import 'package:net_kit/src/models/result.dart';

typedef EncodeResult = Result<ParseException, dynamic>;

abstract interface class NetKitEncoder<E> {
  EncodeResult encode<D>(D data, E Function(D) encoder);
}
