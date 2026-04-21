import 'package:net_kit/src/models/response_context.dart';
import 'package:net_kit/src/services/mappers/response_classifier.dart';

class DefaultResponseClassifier implements ResponseClassifier {
  const DefaultResponseClassifier();

  @override
  bool isError(ResponseContext response) => response.statusCode >= 400;
}
