import 'package:functionals/src/runners.dart';
import 'package:test/test.dart';

void main() {
  group('runCatching', () {
    test('Returns result when runnable succeeds', () {
      final result = runCatching(() => 42, defaultValue: 0);
      expect(result, 42);
    });

    test('Returns defaultValue when runnable throws', () {
      const defaultValue = 99;
      final result = runCatching(
        () => throw Exception('oops'),
        defaultValue: defaultValue,
      );
      expect(result, defaultValue);
    });

    test('Does not log by default', () {
      final result = runCatching(
        () => throw Exception('oops'),
        defaultValue: 0,
      );
      expect(result, 0);
    });

    test('Logs when printLog is true', () {
      final result = runCatching(
        () => throw Exception('oops'),
        defaultValue: 0,
        printLog: true,
      );
      expect(result, 0);
    });
  });
}
