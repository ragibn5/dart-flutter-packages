/// Sets the session data for the analytics service.
abstract interface class SetAnalyticsSessionDataUseCase {
  Future<void> call(String userId, {required bool collectionEnabled});
}
