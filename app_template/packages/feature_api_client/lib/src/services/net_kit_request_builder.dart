import 'package:net_kit/net_kit.dart';

abstract interface class NetKitRequestBuilder<Req> {
  RequestSpec createRequest(Req body);
}
