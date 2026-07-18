import 'package:net_models/net_models.dart';

void main() {
  final success = SuccessResponse<String>(
    data: 'Hello',
    statusCode: 200,
    headers: {},
  );
  final message = success.fold(
    onFailure: (e) => 'Error: $e',
    onSuccess: (data) => 'Data: $data',
  );
  print(message);
}
