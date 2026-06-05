import 'dart:async';

import 'package:mutex/mutex.dart';
import 'package:test/test.dart';

void main() {
  test('No overlapping — second call waits for first to complete', () async {
    final mutex = Mutex();
    var state = 0;

    await Future.wait([
      mutex.synchronized(() async {
        state = 1;
        await Future<void>.delayed(const Duration(milliseconds: 100));
        state = 2;
      }),
      mutex.synchronized(() async {
        expect(state, 2);
      }),
    ]);
  });

  test('Returns value from fn', () async {
    final mutex = Mutex();
    expect(await mutex.synchronized(() async => 42), 42);
  });

  test('Does not block subsequent calls after error', () async {
    final mutex = Mutex();
    final log = <int>[];

    await Future.wait([
      mutex.synchronized(() async {
        log.add(1);
        throw Exception('fail');
      }).then((_) {}, onError: (Object _) {}),
      mutex.synchronized(() async {
        log.add(2);
      }),
    ]);

    expect(log, [1, 2]);
  });
}
