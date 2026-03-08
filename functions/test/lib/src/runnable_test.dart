import 'package:functions/src/runnable.dart';
import 'package:test/test.dart';

void main() {
  test('Returns result when runnable succeeds', () {
    final result = runCatching(() => 42, defaultValue: 0);
    expect(result, 42);
  });

  test('Returns defaultValue when runnable throws', () {
    const defaultValue = 99;
    final result =
        runCatching(() => throw Exception('oops'), defaultValue: defaultValue);
    expect(result, defaultValue);
  });
}
