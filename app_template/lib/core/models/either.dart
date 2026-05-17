sealed class Either<L, R> {
  T fold<T>({required T Function(L) onLeft, required T Function(R) onRight}) {
    final self = this;
    return switch (self) {
      Left<L>() => onLeft(self.l),
      Right<R>() => onRight(self.r),
      _ => throw StateError(
        // ignore: lines_longer_than_80_chars
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
