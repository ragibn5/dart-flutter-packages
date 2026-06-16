import 'package:initializable/initializable.dart';

class DatabaseService implements Initializable {
  @override
  Future<void> initialize() async {
    print('Database initialized');
  }
}

void main() async {
  final service = DatabaseService();
  await service.initialize();
}
