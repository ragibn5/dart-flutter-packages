import 'package:dart_functionals/dart_functionals.dart';

void main() {
  runCatchingExample();
  eitherExample();
  resultExample();
}

/// Demonstrates [runCatching].
///
/// - Returns the result on success.
/// - or the `defaultValue` when the callback throws.
///
/// Note: Set `printLog = true` to log errors (false by default).
void runCatchingExample() {
  final parsedNumber = runCatching(
    () => int.parse('42'),
    defaultValue: 0,
  );
  print(parsedNumber); // 42

  final fallbackNumber = runCatching(
    () => int.parse('hello'),
    defaultValue: 0,
  );
  print(fallbackNumber); // 0

  final loggedFallback = runCatching(
    () => int.parse('hello'),
    defaultValue: 0,
    printErrorLog: true,
  );
  print(loggedFallback); // 0 (error logged)
}

/// Demonstrates [Either]
///
/// A sealed type that is either [Left] or [Right].
void eitherExample() {
  final left = Left('oops');
  final right = Right(42);

  print(left.fold(
    onLeft: (l) => 'Error: $l',
    onRight: (r) => 'Value: $r',
  )); // Error: oops

  print(right.fold(
    onLeft: (l) => 'Error: $l',
    onRight: (r) => 'Value: $r',
  )); // Value: 42
}

/// Demonstrates [Result]
///
/// A sealed type that is either [Failure] or [Success].
void resultExample() {
  final failure = Failure('oops');
  final success = Success(42);

  print(failure.fold(
    onFailure: (f) => 'Error: $f',
    onSuccess: (s) => 'Value: $s',
  )); // Error: oops

  print(success.fold(
    onFailure: (f) => 'Error: $f',
    onSuccess: (s) => 'Value: $s',
  )); // Value: 42
}
