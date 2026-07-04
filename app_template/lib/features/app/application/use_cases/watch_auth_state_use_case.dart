/// A boolean stream that indicates if the user is authenticated in.
///
/// If the user is authenticated, the stream will emit `true`,
/// otherwise it will emit `false`.
abstract interface class WatchAuthStateUseCase {
  Stream<bool> call();
}
