import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:generator_core/generator_core.dart';
import 'package:generator_core/src/models/build_session_context.dart';
import 'package:source_gen/source_gen.dart';

abstract class SessionManagedGeneratorForAnnotation<A, C extends ContextConfig>
    extends GeneratorForAnnotation<A> {
  final BuilderOptions _builderOptions;
  final SessionDataManager _sessionDataManager;

  SessionManagedGeneratorForAnnotation(
    this._builderOptions,
    this._sessionDataManager,
  );

  /// A variant of [GeneratorForAnnotation.generate] that provides
  /// an additional [BuildSessionContext] instance.
  ///
  /// See [GeneratorForAnnotation.generate] method for more details.
  FutureOr<String> generateWithSession(
    LibraryReader library,
    BuildStep buildStep,
    BuildSessionContext<C> sessionContext,
  );

  /// A variant of [GeneratorForAnnotation.generateForAnnotatedElement]
  /// that provides an additional [BuildSessionContext] instance.
  ///
  /// See [GeneratorForAnnotation.generateForAnnotatedElement] method
  /// for more details.
  FutureOr<dynamic> generateForAnnotatedElementWithSession(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
    BuildSessionContext<C> sessionContext,
  );

  /// A variant of [GeneratorForAnnotation.generateForAnnotatedDirective]
  /// that provides an additional [BuildSessionContext] instance.
  ///
  /// See [GeneratorForAnnotation.generateForAnnotatedDirective] method
  /// for more details.
  FutureOr<dynamic> generateForAnnotatedDirectiveWithSession(
    ElementDirective directive,
    ConstantReader annotation,
    BuildStep buildStep,
    BuildSessionContext<C> sessionContext,
  );

  @override
  FutureOr<String> generate(LibraryReader library, BuildStep buildStep) async {
    final sessionContext = await _resolveSessionContext(buildStep);
    if (sessionContext == null) {
      return '';
    }
    return await generateWithSession(library, buildStep, sessionContext);
  }

  @override
  FutureOr<dynamic> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final sessionContext = await _resolveSessionContext(buildStep);
    if (sessionContext == null) return null;
    return await generateForAnnotatedElementWithSession(
      element,
      annotation,
      buildStep,
      sessionContext,
    );
  }

  @override
  FutureOr<dynamic> generateForAnnotatedDirective(
    ElementDirective directive,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final sessionContext = await _resolveSessionContext(buildStep);
    if (sessionContext == null) return null;
    return await generateForAnnotatedDirectiveWithSession(
      directive,
      annotation,
      buildStep,
      sessionContext,
    );
  }

  Future<BuildSessionContext<C>?> _resolveSessionContext(
    BuildStep buildStep,
  ) async {
    final sessionDataFetchResult = await _sessionDataManager.getSessionDataFor(
      buildStep,
      _builderOptions,
    );
    final sessionData = sessionDataFetchResult.sessionData;
    final logger = sessionData.logger;
    final config = sessionData.config;

    if (sessionDataFetchResult.isNewlyCreated) {
      logger.logInfo(
        tag: '$SessionDataManager',
        message: 'Starting session with config:',
        extras: config.toMap(),
      );
    }

    if (config is! C) {
      logger.logWarning(
        tag: '$SessionManagedRawBuilder',
        message:
            'Config type mismatch. '
            'Expected $C, got ${config.runtimeType}. '
            'Ensure correct SessionDataFactory is registered for this plugin.',
      );
      return null;
    }

    return BuildSessionContext(config: config, logger: logger);
  }
}
