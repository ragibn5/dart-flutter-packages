import 'dart:async';

import 'package:build/build.dart';
import 'package:generator_core/src/builders/session_managed_raw_builder.dart';
import 'package:generator_core/src/models/build_session_context.dart';
import 'package:generator_core/src/models/context_config.dart';
import 'package:generator_core/src/services/session/session_data_manager.dart';
import 'package:source_gen/source_gen.dart';

abstract class SessionManagedGenerator<T extends ContextConfig>
    extends Generator {
  final SessionDataManager _sessionDataManager;

  SessionManagedGenerator(this._sessionDataManager);

  /// A variant of [Generator.generate] that provides an additional
  /// [BuildSessionContext] instance.
  ///
  /// See [Generator.generate] method for more details.
  FutureOr<String?> generateWithSession(
    LibraryReader library,
    BuildStep buildStep,
    BuildSessionContext<T> sessionContext,
  );

  @override
  FutureOr<String?> generate(LibraryReader library, BuildStep buildStep) async {
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
      return null;
    }

    return await generateWithSession(
      library,
      buildStep,
      BuildSessionContext(config: config, logger: logger),
    );
  }
}
