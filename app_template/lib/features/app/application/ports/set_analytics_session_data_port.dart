abstract interface class SetAnalyticsSessionDataPort {
  Future<void> call(String userId, {required bool collectionEnabled});
}
