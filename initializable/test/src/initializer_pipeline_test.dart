import 'dart:async';

import 'package:initializable/initializable.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockInitializable extends Mock implements Initializable {}

class _TestPipeline extends InitializerPipeline {
  _TestPipeline(super.initializables);
}

class _ThrowingInitializable implements Initializable {
  @override
  FutureOr<void> initialize() => throw Exception('init failed');
}

void main() {
  test('Should call initialize on every initializable', () async {
    final a = _MockInitializable();
    final b = _MockInitializable();
    when(a.initialize).thenAnswer((_) async {});
    when(b.initialize).thenAnswer((_) async {});

    final pipeline = _TestPipeline([a, b]);
    await pipeline.initialize();

    verify(a.initialize).called(1);
    verify(b.initialize).called(1);
  });

  test('Should call initialize in order', () async {
    final order = <int>[];
    final a = _MockInitializable();
    final b = _MockInitializable();
    when(a.initialize).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      order.add(1);
    });
    when(b.initialize).thenAnswer((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      order.add(2);
    });

    final pipeline = _TestPipeline([a, b]);
    await pipeline.initialize();

    expect(order, [1, 2]);
  });

  test('Should handle empty list', () async {
    final pipeline = _TestPipeline([]);
    await expectLater(pipeline.initialize(), completes);
  });

  test('Should propagate exception from initializable', () async {
    final pipeline = _TestPipeline([_ThrowingInitializable()]);
    await expectLater(pipeline.initialize(), throwsException);
  });
}
