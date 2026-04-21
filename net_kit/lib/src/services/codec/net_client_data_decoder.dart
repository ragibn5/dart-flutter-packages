import 'package:net_kit/src/models/net_client_exception.dart';
import 'package:net_kit/src/models/result.dart';

typedef DecodeResult<D> = Result<ParseException, D>;

abstract interface class NetClientDataDecoder<E> {
  DecodeResult<D> decode<D>(E data, D Function(E) decoder);
}
