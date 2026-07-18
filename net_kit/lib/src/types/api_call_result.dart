import 'package:dart_functionals/dart_functionals.dart';
import 'package:net_kit/src/models/net_kit_exception.dart';
import 'package:net_kit/src/models/net_kit_response.dart';

typedef ApiCallResult = Result<NetKitException, NetKitResponse>;
