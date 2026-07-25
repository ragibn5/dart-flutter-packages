// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: avoid_redundant_argument_values

import 'package:analysis_plugin_test_helper/analysis_plugin_test_helper.dart';
import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_linter/src/models/clean_arch_linter_config.dart';
import 'package:clean_arch_linter/src/models/cross_layer_import_config.dart';
import 'package:clean_arch_linter/src/models/domain_unit_context.dart';
import 'package:clean_arch_linter/src/rules/cross_layer_import/cross_layer_import_visitor.dart';
import 'package:clean_arch_linter/src/services/import_uri_builder/import_uri_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _MockAnalysisRule extends Mock implements AnalysisRule {}

class _MockRuleSessionContext extends Mock
    implements RuleSessionContext<CleanArchLinterConfig> {}

class _MockContextConfig extends Mock implements CleanArchLinterConfig {}

class _MockPackageInfo extends Mock implements PackageInfo {}

class _MockCrossLayerImportConfig extends Mock
    implements CrossLayerImportConfig {}

class _MockSessionLogger extends Mock implements SessionLogger {}

class _MockImportUriBuilder extends Mock implements ImportUriBuilder {}

void main() {
  const defaultContext = DomainUnitContext(
    'lib/features/x/domain/a.dart',
    'lib/features/x/domain/',
  );
  const authDomainContext = DomainUnitContext(
    'lib/feature/auth/domain/services/src.dart',
    'lib/feature/auth/domain/',
  );

  final dartResolver = DartUnitResolver();
  final realImportUriBuilder = ImportUriBuilder();
  final visitorConfig = CrossLayerImportVisitorConfig();

  late _MockAnalysisRule mockAnalysisRule;
  late _MockRuleSessionContext mockRuleSessionContext;
  late _MockContextConfig mockContextConfig;
  late _MockPackageInfo mockPackageInfo;
  late _MockCrossLayerImportConfig mockCrossLayerConfig;
  late _MockSessionLogger mockSessionLogger;
  late _MockImportUriBuilder mockImportUriBuilder;

  late CrossLayerImportVisitor sut;

  void givenImportUri(ImportDirective directive) {
    when(
      () => mockImportUriBuilder.fromImportNode(
        directive,
        hostPath: any(named: 'hostPath'),
      ),
    ).thenAnswer((invocation) {
      final hostPath = invocation.namedArguments[#hostPath] as String;
      return realImportUriBuilder.fromImportNode(directive, hostPath: hostPath);
    });
  }

  void verifyInfoLoggedOnce() {
    verify(
      () => mockRuleSessionContext.logger.logInfo(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
      ),
    ).called(1);
  }

  void verifyNodeReportedOnce(
    ImportDirective directive, {
    required String message,
  }) =>
      verify(
        () => mockAnalysisRule.reportAtNode(
          directive,
          arguments: any(
            named: 'arguments',
            that: predicate<List<Object>>(
              (args) => args.length == 1 && args.first == message,
            ),
          ),
        ),
      ).called(1);

  void verifyNodeNeverReported() => verifyNever(
        () => mockAnalysisRule.reportAtNode(
          any(),
          arguments: any(named: 'arguments'),
        ),
      );

  setUpAll(() async {
    await dartResolver.setUp();
  });

  setUp(() {
    mockAnalysisRule = _MockAnalysisRule();
    mockRuleSessionContext = _MockRuleSessionContext();
    mockContextConfig = _MockContextConfig();
    mockPackageInfo = _MockPackageInfo();
    mockCrossLayerConfig = _MockCrossLayerImportConfig();
    mockSessionLogger = _MockSessionLogger();
    mockImportUriBuilder = _MockImportUriBuilder();

    sut = CrossLayerImportVisitor(
      mockAnalysisRule,
      defaultContext,
      mockRuleSessionContext,
      visitorConfig: visitorConfig,
      importUriBuilder: mockImportUriBuilder,
    );

    when(() => mockRuleSessionContext.config).thenReturn(mockContextConfig);
    when(
      () => mockContextConfig.crossLayerConfig,
    ).thenReturn(mockCrossLayerConfig);
    when(() => mockContextConfig.packageInfo).thenReturn(mockPackageInfo);
    when(() => mockRuleSessionContext.logger).thenReturn(mockSessionLogger);
    when(() => mockCrossLayerConfig.excludedProjectPaths).thenReturn([]);

    when(
      () => mockSessionLogger.logInfo(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
      ),
    ).thenAnswer((_) {});
  });

  tearDownAll(() async {
    await dartResolver.tearDown();
  });

  test(
    'When the import URI cannot be parsed, the directive is ignored and nothing is reported',
    () async {
      final directive = getImportDirective(
        (await dartResolver.resolveSource("import '';")).unit,
      );
      when(
        () => mockImportUriBuilder.fromImportNode(
          directive,
          hostPath: any(named: 'hostPath'),
        ),
      ).thenReturn(null);

      sut.visitImportDirective(directive);

      verifyInfoLoggedOnce();
      verifyNodeNeverReported();
    },
  );

  test(
    'When a relative import points to a domain layer path inside the same feature, the directive is allowed and not reported',
    () async {
      final directive = getImportDirective(
        (await dartResolver.resolveSource(
          "import '../models/auth_data.dart';",
        )).unit,
      );
      givenImportUri(directive);

      sut = CrossLayerImportVisitor(
        mockAnalysisRule,
        authDomainContext,
        mockRuleSessionContext,
        visitorConfig: visitorConfig,
        importUriBuilder: mockImportUriBuilder,
      )..visitImportDirective(directive);

      verifyInfoLoggedOnce();
      verifyNodeNeverReported();
    },
  );

  test(
    'When a relative import points to a domain layer path inside a different feature, the directive is reported',
    () async {
      final directive = getImportDirective(
        (await dartResolver.resolveSource(
          "import '../../other/domain/models/other_data.dart';",
        )).unit,
      );
      givenImportUri(directive);

      sut = CrossLayerImportVisitor(
        mockAnalysisRule,
        authDomainContext,
        mockRuleSessionContext,
        visitorConfig: visitorConfig,
        importUriBuilder: mockImportUriBuilder,
      )..visitImportDirective(directive);

      verifyNodeReportedOnce(
        directive,
        message: visitorConfig.contextMessage,
      );
    },
  );

  test(
    'When a relative import does not target the domain layer but its path is explicitly excluded in the configuration, the directive is ignored',
    () async {
      final directive = getImportDirective(
        (await dartResolver.resolveSource(
          "import '../data/sources/local_auth_data_source.dart';",
        )).unit,
      );
      givenImportUri(directive);

      when(
        () => mockCrossLayerConfig.excludedProjectPaths,
      ).thenReturn(['lib/features/x/data/']);

      sut = CrossLayerImportVisitor(
        mockAnalysisRule,
        defaultContext,
        mockRuleSessionContext,
        visitorConfig: visitorConfig,
        importUriBuilder: mockImportUriBuilder,
      )..visitImportDirective(directive);

      verifyInfoLoggedOnce();
      verifyNodeNeverReported();
    },
  );

  test(
    'When a relative import does not target the domain layer and is not in an excluded project path, the directive is reported',
    () async {
      final directive = getImportDirective(
        (await dartResolver.resolveSource(
          "import '../data/sources/local_auth_data_source.dart';",
        )).unit,
      );
      givenImportUri(directive);

      when(
        () => mockCrossLayerConfig.excludedProjectPaths,
      ).thenReturn(['lib/core/']);

      sut.visitImportDirective(directive);

      verifyNodeReportedOnce(
        directive,
        message: visitorConfig.contextMessage,
      );
    },
  );

  test(
    'When a package import targets the host package and points to a domain layer path in the same feature, the directive is allowed',
    () async {
      final directive = getImportDirective(
        (await dartResolver.resolveSource(
          "import 'package:xyz/feature/auth/domain/services/auth_data_service.dart';",
        )).unit,
      );
      givenImportUri(directive);

      when(() => mockPackageInfo.name).thenReturn('xyz');

      sut = CrossLayerImportVisitor(
        mockAnalysisRule,
        authDomainContext,
        mockRuleSessionContext,
        visitorConfig: visitorConfig,
        importUriBuilder: mockImportUriBuilder,
      )..visitImportDirective(directive);

      verifyInfoLoggedOnce();
      verifyNodeNeverReported();
    },
  );

  test(
    'When a package import targets the host package and points to a domain layer path in a different feature, the directive is reported',
    () async {
      final directive = getImportDirective(
        (await dartResolver.resolveSource(
          "import 'package:xyz/feature/other/domain/models/other_data.dart';",
        )).unit,
      );
      givenImportUri(directive);

      when(() => mockPackageInfo.name).thenReturn('xyz');

      sut = CrossLayerImportVisitor(
        mockAnalysisRule,
        authDomainContext,
        mockRuleSessionContext,
        visitorConfig: visitorConfig,
        importUriBuilder: mockImportUriBuilder,
      )..visitImportDirective(directive);

      verifyNodeReportedOnce(
        directive,
        message: visitorConfig.contextMessage,
      );
    },
  );

  test(
    'When a package import targets the host package and its path is excluded by configuration, the directive is ignored',
    () async {
      final directive = getImportDirective(
        (await dartResolver.resolveSource(
          "import 'package:xyz/core/models/auth_data.dart';",
        )).unit,
      );
      givenImportUri(directive);

      when(() => mockPackageInfo.name).thenReturn('xyz');
      when(
        () => mockCrossLayerConfig.excludedProjectPaths,
      ).thenReturn(['lib/core/']);

      sut.visitImportDirective(directive);

      verifyInfoLoggedOnce();
      verifyNodeNeverReported();
    },
  );

  test(
    'When a non-package import (e.g. dart:) is encountered, the directive is ignored',
    () async {
      final directive = getImportDirective(
        (await dartResolver.resolveSource("import 'dart:core';")).unit,
      );
      givenImportUri(directive);

      when(() => mockPackageInfo.name).thenReturn('xyz');

      sut.visitImportDirective(directive);

      verifyInfoLoggedOnce();
      verifyNodeNeverReported();
    },
  );
}
