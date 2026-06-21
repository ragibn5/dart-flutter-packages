// ignore_for_file: cascade_invocations

import 'package:disposable/disposable.dart';

class DatabaseConnection implements Disposable {
  @override
  void dispose() {
    print('Connection closed');
  }
}

void main() {
  final connection = DatabaseConnection();
  connection.dispose();
}
