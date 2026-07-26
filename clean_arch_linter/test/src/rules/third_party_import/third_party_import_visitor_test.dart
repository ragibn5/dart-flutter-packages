// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: avoid_redundant_argument_values

import 'package:analysis_plugin_test_helper/analysis_plugin_test_helper.dart';
import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_linter/src/models/clean_arch_linter_config.dart';
import 'package:clean_arch_linter/src/models/domain_unit_context.dart';
import 'package:clean_arch_linter/src/models/third_party_import_config.dart';
import 'package:clean_arch_linter/src/rules/third_party_import/third_party_import_visitor.dart';
import 'package:clean_arch_linter/src/services/import_uri_builder/import_uri_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _MockAnalysisRule extends Mock implements AnalysisRule {}

class _MockRuleSessionContext extends Mock
    implements RuleSessionContext<CleanArchLinterConfig> {}

class _MockContextConfig extends Mock implements CleanArchLinterConfig {}

class _MockPackageInfo extends Mock implements PackageInfo {}

class _MockThirdPartyImportConfig extends Mock
    implements ThirdPartyImportConfig {}

class _MockSessionLogger extends Mock implements SessionLogger {}

class _MockImportUriBuilder extends Mock implements ImportUriBuilder {}

void main() {
  const defaultContext = DomainUnitContext(
    'lib/features/x/domain/a.dart',
    'lib/features/x/domain/',
  );

  final dartResolver = DartUnitResolver();
  final realImportUriBuilder = ImportUriBuilder();
  final visitorConfig = ThirdPartyImportVisitorConfig();

  late _MockAnalysisRule mockAnalysisRule;
  late _MockRuleSessionContext mockRuleSessionContext;
  late _MockContextConfig mockContextConfig;
  late _MockPackageInfo mockPackageInfo;
  late _MockThirdPartyImportConfig mockThirdPartyConfig;
  late _MockSessionLogger mockSessionLogger;
  late _MockImportUriBuilder mockImportUriBuilder;

  late ThirdPartyImportVisitor sut;

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
  }) => verify(
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
    mockThirdPartyConfig = _MockThirdPartyImportConfig();
    mockSessionLogger = _MockSessionLogger();
    mockImportUriBuilder = _MockImportUriBuilder();

    sut = ThirdPartyImportVisitor(
      mockAnalysisRule,
      defaultContext,
      mockRuleSessionContext,
      visitorConfig: visitorConfig,
      importUriBuilder: mockImportUriBuilder,
    );

    when(() => mockRuleSessionContext.config).thenReturn(mockContextConfig);
    when(
      () => mockContextConfig.thirdPartyConfig,
    ).thenReturn(mockThirdPartyConfig);
    when(() => mockContextConfig.packageInfo).thenReturn(mockPackageInfo);
    when(() => mockRuleSessionContext.logger).thenReturn(mockSessionLogger);
    when(() => mockThirdPartyConfig.excludedLibraryPackages).thenReturn([]);

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
    'When a third party package import matches an excluded library prefix, the directive is ignored',
    () async {
      final directive = getImportDirective(
        (await dartResolver.resolveSource(
          "import 'package:dartz/functional/fold.dart';",
        )).unit,
      );
      givenImportUri(directive);

      when(() => mockPackageInfo.name).thenReturn('xyz');
      when(
        () => mockThirdPartyConfig.excludedLibraryPackages,
      ).thenReturn(['dartz']);

      sut.visitImportDirective(directive);

      verifyInfoLoggedOnce();
      verifyNodeNeverReported();
    },
  );

  test(
    'When a third party package import is not excluded by configuration, the directive is reported',
    () async {
      final directive = getImportDirective(
        (await dartResolver.resolveSource(
          "import 'package:dartz/functional/fold.dart';",
        )).unit,
      );
      givenImportUri(directive);

      when(() => mockPackageInfo.name).thenReturn('xyz');
      when(() => mockThirdPartyConfig.excludedLibraryPackages).thenReturn([]);

      sut.visitImportDirective(directive);

      verifyNodeReportedOnce(directive, message: visitorConfig.contextMessage);
    },
  );

  test(
    'When an own-package import is encountered, the directive is ignored',
    () async {
      final directive = getImportDirective(
        (await dartResolver.resolveSource(
          "import 'package:xyz/feature/data/models/data.dart';",
        )).unit,
      );
      givenImportUri(directive);

      when(() => mockPackageInfo.name).thenReturn('xyz');

      sut.visitImportDirective(directive);

      verifyInfoLoggedOnce();
      verifyNodeNeverReported();
    },
  );

  test(
    'When a non-package import (e.g. relative) is encountered, the directive is ignored',
    () async {
      final directive = getImportDirective(
        (await dartResolver.resolveSource(
          "import '../models/data.dart';",
        )).unit,
      );
      givenImportUri(directive);

      when(() => mockPackageInfo.name).thenReturn('xyz');

      sut.visitImportDirective(directive);

      verifyInfoLoggedOnce();
      verifyNodeNeverReported();
    },
  );

  test(
    'When a dart SDK import is encountered, the directive is ignored',
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
