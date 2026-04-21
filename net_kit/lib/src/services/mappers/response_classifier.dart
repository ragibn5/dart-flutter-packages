import 'package:net_kit/src/models/response_context.dart';

abstract interface class ResponseClassifier {
  /// Determines whether a [response] should be treated as an error.
  bool isError(ResponseContext response);
}
