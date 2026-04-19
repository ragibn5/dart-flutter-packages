import 'package:net_kit/net_kit.dart';
import 'package:net_kit/src/models/api_response.dart';

typedef ApiCallResult<Req, Res, Err>
    = Result<NetKitException, ApiResponse<Req, Res, Err>>;
