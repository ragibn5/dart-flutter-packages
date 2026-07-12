/// Get whether the user is authenticated or not.
abstract interface class IsAuthedUseCase {
  Future<bool> call();
}
