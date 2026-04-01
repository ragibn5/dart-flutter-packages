// ignore_for_file: implementation_imports

import 'dart:async';

import 'package:build/build.dart';
import 'package:generator_core/src/models/session_data.dart';
import 'package:generator_core/src/models/session_data_fetch_result.dart';
import 'package:generator_core/src/services/config/context_config_loader.dart';
import 'package:generator_core/src/services/session/session_data_factory.dart';
import 'package:meta/meta.dart';

abstract interface class SessionDataManager {
  /// Get a [SessionDataFetchResult] instance having:
  /// - A flag whether it was newly created.
  /// - The managed [SessionData] instance (possibly cached)
  ///   for the given [BuildStep].
  Future<SessionDataFetchResult> getSessionDataFor(BuildStep buildStep);

  factory SessionDataManager.createNewInstance(
    ContextConfigLoader packageConfigLoader,
  ) => SessionDataManagerImpl(SessionDataFactoryImpl(packageConfigLoader));
}

class SessionDataManagerImpl implements SessionDataManager {
  final Map<String, SessionData> _cache;

  final SessionDataFactory _factory;

  SessionDataManagerImpl(SessionDataFactory sessionDataFactory)
    : this._({}, sessionDataFactory);

  @visibleForTesting
  SessionDataManagerImpl.test(
    Map<String, SessionData> sessionDataMap,
    SessionDataFactory sessionDataFactory,
  ) : this._(sessionDataMap, sessionDataFactory);

  SessionDataManagerImpl._(this._cache, this._factory);

  @override
  Future<SessionDataFetchResult> getSessionDataFor(BuildStep buildStep) async {
    final package = buildStep.inputId.package;
    final current = _cache[package];
    if (current != null) {
      return SessionDataFetchResult(
        isNewlyCreated: false,
        sessionData: current,
      );
    }

    _cache[package] = await _factory.createSessionData(buildStep);

    return SessionDataFetchResult(
      isNewlyCreated: true,
      sessionData: _cache[package]!,
    );
  }
}
