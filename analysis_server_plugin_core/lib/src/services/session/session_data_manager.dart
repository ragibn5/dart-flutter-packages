import 'package:analysis_server_plugin_core/src/models/session_data.dart';
import 'package:analysis_server_plugin_core/src/models/session_data_fetch_result.dart';
import 'package:analysis_server_plugin_core/src/services/session/session_data_factory.dart';
import 'package:analyzer/analysis_rule/rule_context.dart';
import 'package:meta/meta.dart';

abstract interface class SessionDataManager {
  /// Get a [SessionDataFetchResult] instance having:
  /// - A flag whether it was newly created.
  /// - The managed [SessionData] instance (possibly cached)
  ///   for the given [RuleContext].
  SessionDataFetchResult getSessionDataFor(RuleContext context);
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
  SessionDataFetchResult getSessionDataFor(RuleContext context) {
    final packageRoot =
        context.package?.root.path ?? context.definingUnit.file.parent.path;

    final current = _cache[packageRoot];
    if (current != null) {
      return SessionDataFetchResult(
        isNewlyCreated: false,
        sessionData: current,
      );
    }

    _cache[packageRoot] = _factory.createSessionData(context);

    return SessionDataFetchResult(
      isNewlyCreated: true,
      sessionData: _cache[packageRoot]!,
    );
  }
}
