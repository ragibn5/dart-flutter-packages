/// Sets the session data for the crashlytics service.
abstract interface class SetCrashlyticsSessionDataUseCase {
  Future<void> call(String userId, {required bool collectionEnabled});
}
