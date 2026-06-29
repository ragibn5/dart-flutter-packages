abstract interface class SetAnalyticsSessionDataUseCase {
  /// Sets the session data for the crashlytics service.
  Future<void> call(String userId, {required bool collectionEnabled});
}
