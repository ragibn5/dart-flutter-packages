// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/core/contracts/initializable.dart';
import 'package:app_template/features/app/application/services/app_initializer_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockInitializable extends Mock implements Initializable {}

void main() {
  const size = 100;

  late List<_MockInitializable> mockInitializables;

  late AppInitializerServiceImpl sut;

  setUp(() {
    // Create 'size' number of mocks dynamically
    mockInitializables = List.generate(size, (_) => _MockInitializable());

    sut = AppInitializerServiceImpl(mockInitializables);
  });

  test('Should initialize all initializables', () async {
    await sut.initialize();
    for (final mock in mockInitializables) {
      verify(mock.initialize).called(1);
    }
  });
}
