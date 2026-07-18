import 'package:net_models/net_models.dart';
import 'package:net_kit/net_kit.dart';

abstract interface class NetKitResponseDecoder<Err, Res> {
  ApiResponse<Err, Res> decodeResponse(NetKitResponse response);
}
