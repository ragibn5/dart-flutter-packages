import 'package:dart_functionals/dart_functionals.dart';
import 'package:test/test.dart';

void main() {
  group('Left', () {
    test('Should store value', () {
      final left = Left(42);
      expect(left.l, 42);
    });

    test('isLeft should be true', () {
      expect(Left(1).isLeft, true);
    });

    test('isRight should be false', () {
      expect(Left(1).isRight, false);
    });
  });

  group('Right', () {
    test('Should store value', () {
      final right = Right('hello');
      expect(right.r, 'hello');
    });

    test('isRight should be true', () {
      expect(Right(1).isRight, true);
    });

    test('isLeft should be false', () {
      expect(Right(1).isLeft, false);
    });
  });

  group('Either', () {
    test('fold should call onLeft for Left', () {
      final result = Left(42).fold(
        onLeft: (l) => 'left: $l',
        onRight: (r) => 'right: $r',
      );
      expect(result, 'left: 42');
    });

    test('fold should call onRight for Right', () {
      final result = Right(42).fold(
        onLeft: (l) => 'left: $l',
        onRight: (r) => 'right: $r',
      );
      expect(result, 'right: 42');
    });

    test('leftOrThrow should return value for Left', () {
      expect(Left(42).leftOrThrow, 42);
    });

    test('leftOrThrow should throw for Right', () {
      expect(
        () => Right('x').leftOrThrow,
        throwsStateError,
      );
    });

    test('rightOrThrow should return value for Right', () {
      expect(Right(42).rightOrThrow, 42);
    });

    test('rightOrThrow should throw for Left', () {
      expect(
        () => Left(1).rightOrThrow,
        throwsStateError,
      );
    });
  });
}
