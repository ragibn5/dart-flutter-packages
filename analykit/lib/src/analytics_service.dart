import 'package:meta/meta.dart';

abstract class AnalyticsService {
  const AnalyticsService();

  /// Initializes the analytics service.
  ///
  /// Must be called before any other methods.
  @mustCallSuper
  Future<void> initialize() async {}

  /// Associates analytics data with the given [userId]; `null` clears it,
  /// such as on sign-out.
  Future<void> setUserId(String? userId);

  /// Turns analytics collection on or off.
  ///
  /// Note:
  /// The provider remembers it across launches.
  Future<void> setCollectionEnabled({required bool enabled});

  /// Logs an analytics event with the given [name] and optional parameters.
  Future<void> logEvent(String name, [Map<String, Object>? params]);
}
