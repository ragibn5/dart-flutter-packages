import 'package:net_kit/src/models/api_response.dart';
import 'package:net_kit/src/models/net_kit_exception.dart';
import 'package:net_kit/src/models/result.dart';

typedef ApiCallResult = Result<NetKitException, ApiResponse>;
