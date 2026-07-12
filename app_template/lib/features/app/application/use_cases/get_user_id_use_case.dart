/// Returns the user ID of the current user.
abstract interface class GetUserIdUseCase {
  Future<String?> call();
}
