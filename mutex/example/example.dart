import 'package:mutex/mutex.dart';

void main() async {
  final mutex = Mutex();
  final result = await mutex.synchronized(() async {
    return 'Hello from synchronized block';
  });

  print(result);
}
