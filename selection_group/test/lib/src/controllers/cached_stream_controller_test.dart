import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:selection_group/src/controllers/cached_stream_controller.dart';

class _MockStream extends Mock implements Stream<int> {}

class _MockStreamController extends Mock implements StreamController<int> {}

void main() {
  late _MockStream mockStream;
  late _MockStreamController mockController;

  late CachedStreamController<int> sut;

  setUp(() {
    mockStream = _MockStream();
    mockController = _MockStreamController();

    sut = CachedStreamController.test(mockController);

    when(() => mockController.add(any())).thenAnswer((_) {});
    when(() => mockController.close()).thenAnswer((_) async {});
    when(() => mockController.stream).thenAnswer((_) => mockStream);
  });

  test('add(...) should add item to stream and store the last item', () {
    const itemToAdd = 1;

    sut.add(itemToAdd);

    expect(sut.lastItem, itemToAdd);
    verify(() => mockController.add(itemToAdd)).called(1);
  });

  test('close should close the underlying stream', () {
    sut.close();

    verify(() => mockController.close()).called(1);
  });
}
