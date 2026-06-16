import 'package:core_models/core_models.dart';

void main() {
  final success = Success<String>(
    data: 'Hello',
    statusCode: 200,
    headers: {},
  );
  final message = success.fold(
    onFailure: (e) => 'Error: $e',
    onSuccess: (data) => 'Data: $data',
  );
  print(message);

  final either = Right<int>(42);
  final value = either.fold(
    onLeft: (l) => -1,
    onRight: (r) => r,
  );
  print('The answer is $value');
}
