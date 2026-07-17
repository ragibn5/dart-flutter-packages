# dart_functionals

A collection of reusable functions missing in core dart sdk.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  dart_functionals: ^1.0.1
```

#### Or, From Git repo

```yaml
dependencies:
  dart_functionals:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: dart_functionals
      ref: dart_functionals-1.0.1
```

## Get Started

### runCatching

A top level function that runs the given lambda and returns the result of the lambda, or a `defaultValue` when it throws. You can set `printErrorLog = true` to log errors.

```dart
final result = runCatching(
  () => int.parse('42'),
  defaultValue: 0,
);
// result: 42

final fallback = runCatching(
  () => int.parse('hello'),
  defaultValue: 0,
);
// fallback: 0

final logged = runCatching(
  () => int.parse('hello'),
  defaultValue: 0,
  printErrorLog: true, // Set to true to log errors, false by default.
);
// logged: 0 (error logged)
```

### Either

A type that is one of [Left] or [Right].

```dart
final left = Left('oops');
final right = Right(42);

left.isLeft;  // true
left.leftOrThrow;  // oops

right.isRight;  // true
right.rightOrThrow;  // 42

final msg = left.fold(
  onLeft: (l) => 'Error: $l',
  onRight: (r) => 'Value: $r',
);
// msg: Error: oops
```

### Result

A type that is one of [Failure] or [Success].

```dart
final failure = Failure('oops');
final success = Success(42);

failure.isFailure;  // true
failure.failureOrThrow;  // oops

success.isSuccess;  // true
success.successOrThrow;  // 42

final msg = success.fold(
  onFailure: (f) => 'Error: $f',
  onSuccess: (s) => 'Value: $s',
);
// msg: Value: 42
```

## Example

See the [example](example/example.dart) for a complete demonstration.
