sealed class Result<F, S> {
  T fold<T>({
    required T Function(F) onFailure,
    required T Function(S) onSuccess,
  }) {
    final self = this;
    return switch (self) {
      Failure<F>() => onFailure(self.f),
      Success<S>() => onSuccess(self.s),
      _ => throw StateError(
          'Invalid state: expected Failure or Success',
        ),
    };
  }

  bool get isFailure => this is Failure<F>;

  bool get isSuccess => this is Success<S>;

  F get failureOrThrow {
    final self = this;
    return switch (self) {
      Failure<F>() => self.f,
      Success<S>() => throw StateError(
          'Expected Failure, but was Success(${self.s})',
        ),
      _ => throw StateError(
          'Invalid state: expected Failure or Success',
        ),
    };
  }

  S get successOrThrow {
    final self = this;
    return switch (self) {
      Success<S>() => self.s,
      Failure<F>() => throw StateError(
          'Expected Success, but was Failure(${self.f})',
        ),
      _ => throw StateError(
          'Invalid state: expected Failure or Success',
        ),
    };
  }
}

final class Failure<F> extends Result<F, Never> {
  final F f;

  Failure(this.f);
}

final class Success<S> extends Result<Never, S> {
  final S s;

  Success(this.s);
}
