abstract interface class GetUserIdUseCase {
  /// Returns the user ID of the current user.
  Future<String?> call();
}
