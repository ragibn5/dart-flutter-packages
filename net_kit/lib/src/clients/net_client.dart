import 'dart:async';

import 'package:net_kit/src/models/request_spec.dart';
import 'package:net_kit/src/services/cancellation/request_canceller.dart';
import 'package:net_kit/src/services/codec/response_data_codec.dart';
import 'package:net_kit/src/services/mappers/response_classifier.dart';
import 'package:net_kit/src/types/api_call_result.dart';
import 'package:net_kit/src/types/progress_listener.dart';

abstract interface class NetClient {
  /// Executes the given [spec] and returns a typed [ApiCallResult].
  Future<ApiCallResult<Res, Err>> execute<Res, Err>({
    required RequestSpec spec,
    required ResponseDataCodec<Res, Err> codec,
    ResponseClassifier responseClassifier = const DefaultResponseClassifier(),
    ProgressListener? onSendProgress,
    ProgressListener? onReceiveProgress,
    RequestCanceller? requestCanceller,
  });

  /// Closes the underlying HTTP client and frees its resources.
  void close();
}
