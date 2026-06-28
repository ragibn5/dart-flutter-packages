abstract interface class SetCrashlyticsSessionDataPort {
  Future<void> call(String userId, {required bool collectionEnabled});
}
