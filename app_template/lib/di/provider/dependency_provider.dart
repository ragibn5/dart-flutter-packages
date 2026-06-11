import 'dart:async';

import 'package:app_template/features/app/infrastructure/enums/app_flavor.dart';

abstract interface class DependencyProvider {
  T get<T extends Object>({String? name});

  T? getOrNull<T extends Object>({String? name});

  FutureOr<void> initialize(AppFlavor? flavor);

  FutureOr<void> dispose();

  void registerSingleton<T extends Object>(
    T instance, {
    String? instanceName,
    FutureOr<T> Function(T param)? disposeFunc,
  });

  void registerLazySingleton<T extends Object>(
    T Function() factoryFunc, {
    String? instanceName,
    FutureOr<T> Function(T param)? disposeFunc,
  });

  void registerFactory<T extends Object>(
    T Function() factoryFunc, {
    String? instanceName,
  });
}
