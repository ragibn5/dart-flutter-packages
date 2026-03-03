// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/core/contracts/initializable.dart';
import 'package:app_template/features/app/application/services/app_initializer_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockInitializable extends Mock implements Initializable {}

void main() {
  const size = 100;
  late List<_MockInitializable> initializables;
  late AppInitializerServiceImpl appInitializerServiceImpl;

  setUp(() {
    // Create 'size' number of mocks dynamically
    initializables = List.generate(size, (_) => _MockInitializable());
    appInitializerServiceImpl = AppInitializerServiceImpl(initializables);
  });

  test('Should initialize all initializables', () async {
    await appInitializerServiceImpl.initialize();
    for (final mock in initializables) {
      verify(mock.initialize).called(1);
    }
  });
}
