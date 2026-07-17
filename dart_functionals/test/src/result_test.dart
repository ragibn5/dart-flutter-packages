import 'package:dart_functionals/dart_functionals.dart';
import 'package:test/test.dart';

void main() {
  group('Failure', () {
    test('Should store value', () {
      final failure = Failure(42);
      expect(failure.f, 42);
    });

    test('isFailure should be true', () {
      expect(Failure(1).isFailure, true);
    });

    test('isSuccess should be false', () {
      expect(Failure(1).isSuccess, false);
    });
  });

  group('Success', () {
    test('Should store value', () {
      final success = Success('hello');
      expect(success.s, 'hello');
    });

    test('isSuccess should be true', () {
      expect(Success(1).isSuccess, true);
    });

    test('isFailure should be false', () {
      expect(Success(1).isFailure, false);
    });
  });

  group('Result', () {
    test('fold should call onFailure for Failure', () {
      final result = Failure(42).fold(
        onFailure: (l) => 'error: $l',
        onSuccess: (r) => 'ok: $r',
      );
      expect(result, 'error: 42');
    });

    test('fold should call onSuccess for Success', () {
      final result = Success(42).fold(
        onFailure: (l) => 'error: $l',
        onSuccess: (r) => 'ok: $r',
      );
      expect(result, 'ok: 42');
    });

    test('failureOrThrow should return value for Failure', () {
      expect(Failure(42).failureOrThrow, 42);
    });

    test('failureOrThrow should throw for Success', () {
      expect(
        () => Success('x').failureOrThrow,
        throwsStateError,
      );
    });

    test('successOrThrow should return value for Success', () {
      expect(Success(42).successOrThrow, 42);
    });

    test('successOrThrow should throw for Failure', () {
      expect(
        () => Failure(1).successOrThrow,
        throwsStateError,
      );
    });
  });
}
