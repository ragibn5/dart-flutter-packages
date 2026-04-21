import 'package:net_kit/src/models/api_response.dart';
import 'package:net_kit/src/models/net_client_exception.dart';
import 'package:net_kit/src/models/result.dart';

typedef ApiCallResult<Req, Res, Err>
    = Result<NetClientException, ApiResponse<Req, Res, Err>>;
