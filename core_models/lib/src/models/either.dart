sealed class Either<L, R> {
  T fold<T>({required T Function(L) onLeft, required T Function(R) onRight}) {
    final self = this;
    return switch (self) {
      Left<L>() => onLeft(self.l),
      Right<R>() => onRight(self.r),
      _ => throw StateError(
          'Invalid state: should have been either ${Left<L>}, or ${Right<R>}',
        ),
    };
  }

  bool get isLeft => this is Left<L>;

  bool get isRight => this is Right<R>;

  L get leftOrThrow {
    final self = this;
    return switch (self) {
      Left<L>() => self.l,
      Right<R>() => throw StateError(
          'Expected Left, but was Right(${self.r})',
        ),
      _ => throw StateError(
          'Invalid state: should have been either ${Left<L>}, or ${Right<R>}',
        ),
    };
  }

  R get rightOrThrow {
    final self = this;
    return switch (self) {
      Right<R>() => self.r,
      Left<L>() => throw StateError(
          'Expected Right, but was Left(${self.l})',
        ),
      _ => throw StateError(
          'Invalid state: should have been either ${Left<L>}, or ${Right<R>}',
        ),
    };
  }
}

final class Left<L> extends Either<L, Never> {
  final L l;

  Left(this.l);
}

final class Right<R> extends Either<Never, R> {
  final R r;

  Right(this.r);
}
