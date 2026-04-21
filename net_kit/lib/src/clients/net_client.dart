import 'dart:async';

import 'package:net_kit/src/models/request_spec.dart';
import 'package:net_kit/src/models/result.dart';
import 'package:net_kit/src/services/request_canceller.dart';
import 'package:net_kit/src/services/request_codec.dart';
import 'package:net_kit/src/services/response_classifier.dart';
import 'package:net_kit/src/types/api_call_result.dart';
import 'package:net_kit/src/types/progress_listener.dart';

abstract interface class NetClient {
  /// Executes the given [spec] and returns a typed [Result].
  Future<ApiCallResult<Req, Res, Err>> execute<Req, Res, Err>({
    required RequestSpec<Req> spec,
    required RequestCodec<Req, Res, Err> codec,
    ResponseClassifier responseClassifier = const DefaultResponseClassifier(),
    ProgressListener? onSendProgress,
    ProgressListener? onReceiveProgress,
    RequestCanceller<Req>? requestCanceller,
  });

  /// Closes the underlying HTTP client and frees its resources.
  void close();
}
