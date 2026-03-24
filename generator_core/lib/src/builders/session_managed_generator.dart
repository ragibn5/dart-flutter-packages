import 'dart:async';

import 'package:generator_core/generator_core.dart';
import 'package:generator_core/src/models/build_session_context.dart';
import 'package:source_gen/source_gen.dart';

abstract class SessionManagedGenerator<T extends ContextConfig>
    extends Generator {
  final BuilderOptions _builderOptions;
  final SessionDataManager _sessionDataManager;

  SessionManagedGenerator(this._builderOptions, this._sessionDataManager);

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
      _builderOptions,
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
