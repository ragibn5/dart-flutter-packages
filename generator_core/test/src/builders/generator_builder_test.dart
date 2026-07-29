import 'dart:async';

import 'package:build/build.dart';
import 'package:generator_core/src/builders/generator_builder.dart';
import 'package:generator_core/src/builders/session_managed_generator.dart';
import 'package:generator_core/src/builders/session_managed_generator_for_annotation.dart';
import 'package:generator_core/src/builders/session_managed_raw_builder.dart';
import 'package:generator_core/src/models/build_session_context.dart';
import 'package:generator_core/src/models/context_config.dart';
import 'package:generator_core/src/services/config/context_config_loader.dart';
import 'package:generator_core/src/services/session/session_data_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _MockContextConfigLoader extends Mock
    implements ContextConfigLoader<_TestConfig> {}

class _TestConfig extends ContextConfig {
  const _TestConfig({required super.logConfig});

  @override
  Map<String, dynamic> toMap() => {};
}

class _TestRawBuilder extends SessionManagedRawBuilder<_TestConfig> {
  _TestRawBuilder(super.sessionDataManager);

  @override
  Map<String, List<String>> get buildExtensions => {};

  @override
  Future<void> buildWithSession(
    BuildStep buildStep,
    BuildSessionContext<_TestConfig> sessionContext,
  ) async {}
}

class _TestGenerator extends SessionManagedGenerator<_TestConfig> {
  _TestGenerator(super.sessionDataManager);

  @override
  FutureOr<String> generateWithSession(
    LibraryReader library,
    BuildStep buildStep,
    BuildSessionContext<_TestConfig> sessionContext,
  ) => '';
}

class _TestAnnotation {}

class _TestAnnotationGenerator
    extends SessionManagedGeneratorForAnnotation<_TestAnnotation, _TestConfig> {
  _TestAnnotationGenerator(super.sessionDataManager);

  @override
  FutureOr<String> generateWithSession(
    LibraryReader library,
    BuildStep buildStep,
    BuildSessionContext<_TestConfig> sessionContext,
  ) => '';

  @override
  Future<dynamic> generateForAnnotatedElementWithSession(
    dynamic element,
    ConstantReader annotation,
    BuildStep buildStep,
    BuildSessionContext<_TestConfig> sessionContext,
  ) async => null;

  @override
  Future<dynamic> generateForAnnotatedDirectiveWithSession(
    dynamic directive,
    ConstantReader annotation,
    BuildStep buildStep,
    BuildSessionContext<_TestConfig> sessionContext,
  ) async => null;
}

void main() {
  late _MockContextConfigLoader mockConfigLoader;

  setUp(() {
    mockConfigLoader = _MockContextConfigLoader();
  });

  group('GeneratorBuilder', () {
    test('build() returns the instance produced by the factory', () {
      final builder = GeneratorBuilder<_TestConfig, _TestRawBuilder>(
        configLoader: mockConfigLoader,
        factory: _TestRawBuilder.new,
      ).build();

      expect(builder, isA<_TestRawBuilder>());
    });

    test('build() creates a fresh instance on each call', () {
      final gb = GeneratorBuilder<_TestConfig, _TestRawBuilder>(
        configLoader: mockConfigLoader,
        factory: _TestRawBuilder.new,
      );

      final first = gb.build();
      final second = gb.build();

      expect(identical(first, second), isFalse);
    });

    test('factory receives a SessionDataManager', () {
      SessionDataManager? captured;

      GeneratorBuilder<_TestConfig, _TestRawBuilder>(
        configLoader: mockConfigLoader,
        factory: (sdm) {
          captured = sdm;
          return _TestRawBuilder(sdm);
        },
      ).build();

      expect(captured, isA<SessionDataManager>());
    });

    test('works with SessionManagedGenerator', () {
      final generator = GeneratorBuilder<_TestConfig, _TestGenerator>(
        configLoader: mockConfigLoader,
        factory: _TestGenerator.new,
      ).build();

      expect(generator, isA<_TestGenerator>());
    });

    test('works with SessionManagedGeneratorForAnnotation', () {
      final generator = GeneratorBuilder<_TestConfig, _TestAnnotationGenerator>(
        configLoader: mockConfigLoader,
        factory: _TestAnnotationGenerator.new,
      ).build();

      expect(generator, isA<_TestAnnotationGenerator>());
    });
  });
}
