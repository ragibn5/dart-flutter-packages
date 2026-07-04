/// Get whether the user is authenticated or not.
abstract interface class GetAuthStateUseCase {
  Future<bool> call();
}
