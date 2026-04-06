import 'package:functions/functions.dart';

void main() {
  // Returns the computed value when the callback succeeds.
  final parsedNumber = runCatching(
    () => int.parse('42'),
    defaultValue: 0,
  );
  print(parsedNumber); // 42

  // Returns the provided fallback when the callback throws.
  final fallbackNumber = runCatching(
    () => int.parse('hello'),
    defaultValue: 0,
  );
  print(fallbackNumber); // 0
}
