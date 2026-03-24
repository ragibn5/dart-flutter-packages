import 'dart:async';

import 'package:generator_core/generator_core.dart';
import 'package:generator_core/src/models/build_session_context.dart';

abstract class SessionManagedRawBuilder<T extends ContextConfig>
    implements Builder {
  final SessionDataManager _sessionDataManager;

  SessionManagedRawBuilder(this._sessionDataManager);

  FutureOr<void> buildWithSession(
    BuildStep buildStep,
    BuildSessionContext<T> sessionContext,
  );

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final sessionDataFetchResult = await _sessionDataManager.getSessionDataFor(
      buildStep,
    );
    final sessionData = sessionDataFetchResult.sessionData;
    final logger = sessionData.logger;
    final config = sessionData.config;
    if (sessionDataFetchResult.isNewlyCreated) {
      sessionData.logger.logInfo(
        tag: '$SessionDataManager',
        message: 'Starting session with config:',
        extras: sessionData.config.toMap(),
      );
    }

    if (config is! T) {
      logger.logWarning(
        tag: '$SessionManagedRawBuilder',
        message:
            'Config type mismatch. '
            'Expected $T, got ${config.runtimeType}. '
            'Ensure correct SessionDataFactory is registered for this plugin.',
      );
      return;
    }

    await buildWithSession(
      buildStep,
      BuildSessionContext(config: config, logger: logger),
    );
  }
}
