// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: avoid_redundant_argument_values

import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:clean_arch_lint/src/models/clean_arch_lint_config.dart';
import 'package:clean_arch_lint/src/models/ddr_config.dart';
import 'package:clean_arch_lint/src/rules/dependency_direction_rule/dependency_direction_rule_visitor.dart';
import 'package:clean_arch_lint/src/services/import_uri_builder/import_uri_builder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

class _MockAnalysisRule extends Mock implements AnalysisRule {}

class _MockRuleSessionContext extends Mock
    implements RuleSessionContext<CleanArchLintConfig> {}

class _MockContextConfig extends Mock implements CleanArchLintConfig {}

class _MockPackageInfo extends Mock implements PackageInfo {}

class _MockDependencyDirectionRuleConfig extends Mock
    implements DependencyDirectionRuleConfig {}

class _MockSessionLogger extends Mock implements SessionLogger {}

class _MockImportUriBuilder extends Mock implements ImportUriBuilder {}

void main() {
  final realImportUriBuilder = ImportUriBuilder();

  late _MockAnalysisRule mockAnalysisRule;
  late _MockRuleSessionContext mockRuleSessionContext;
  late _MockContextConfig mockContextConfig;
  late _MockPackageInfo mockPackageInfo;
  late _MockDependencyDirectionRuleConfig mockDDRConfig;
  late _MockSessionLogger mockSessionLogger;
  late _MockImportUriBuilder mockImportUriBuilder;

  late DependencyDirectionRuleVisitor sut;

  ImportDirective? parseImportDirective(String content) {
    return parseString(
      content: content,
    ).unit.directives.whereType<ImportDirective>().firstOrNull;
  }

  ImportDirective parseValidImportDirective(String content) {
    final importDirective = parseImportDirective(content);
    if (importDirective == null) {
      fail('Expected valid import directive definition, got: |$content|');
    }

    return importDirective;
  }

  void givenImportUri(ImportDirective directive) {
    when(
      () => mockImportUriBuilder.fromImportNode(directive),
    ).thenReturn(realImportUriBuilder.fromImportNode(directive));
  }

  void verifyInfoLoggedOnce() {
    verify(
      () => mockRuleSessionContext.logger.logInfo(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
      ),
    ).called(1);
  }

  void verifyNodeReportedOnce(ImportDirective directive) =>
      verify(() => mockAnalysisRule.reportAtNode(directive)).called(1);

  void verifyNodeNeverReported() =>
      verifyNever(() => mockAnalysisRule.reportAtNode(any()));

  setUp(() {
    mockAnalysisRule = _MockAnalysisRule();
    mockRuleSessionContext = _MockRuleSessionContext();
    mockContextConfig = _MockContextConfig();
    mockPackageInfo = _MockPackageInfo();
    mockDDRConfig = _MockDependencyDirectionRuleConfig();
    mockSessionLogger = _MockSessionLogger();
    mockImportUriBuilder = _MockImportUriBuilder();

    sut = DependencyDirectionRuleVisitor.test(
      mockAnalysisRule,
      mockRuleSessionContext,
      mockImportUriBuilder,
    );

    when(() => mockRuleSessionContext.config).thenReturn(mockContextConfig);
    when(() => mockContextConfig.ddrConfig).thenReturn(mockDDRConfig);
    when(() => mockContextConfig.packageInfo).thenReturn(mockPackageInfo);
    when(() => mockRuleSessionContext.logger).thenReturn(mockSessionLogger);

    when(
      () => mockSessionLogger.logInfo(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
      ),
    ).thenAnswer((_) {});
  });

  test(
    'When the import URI cannot be parsed, the directive is ignored and nothing is reported',
    () {
      final directive = parseValidImportDirective("import '';");
      when(
        () => mockImportUriBuilder.fromImportNode(directive),
      ).thenReturn(null);

      sut.visitImportDirective(directive);

      verifyInfoLoggedOnce();
      verifyNodeNeverReported();
    },
  );

  test(
    'When the import is from the Dart SDK and core packages are excluded by configuration, the directive is ignored',
    () {
      final directive = parseValidImportDirective("import 'dart:core';");
      givenImportUri(directive);

      when(() => mockDDRConfig.excludeCoreDartPackages).thenReturn(true);

      sut.visitImportDirective(directive);

      verifyInfoLoggedOnce();
      verifyNodeNeverReported();
    },
  );

  test(
    'When the import is from the Dart SDK and core packages are not excluded, the directive is reported',
    () {
      final directive = parseValidImportDirective("import 'dart:core';");
      givenImportUri(directive);

      when(() => mockDDRConfig.excludeCoreDartPackages).thenReturn(false);

      sut.visitImportDirective(directive);

      verifyInfoLoggedOnce();
      verifyNodeReportedOnce(directive);
    },
  );

  test(
    'When a relative import points to a domain layer path inside the host package, the directive is allowed and not reported',
    () {
      final directive = parseValidImportDirective(
        "import 'feature/auth/domain/services/auth_data_service.dart';",
      );
      givenImportUri(directive);

      when(() => mockDDRConfig.domainDirName).thenReturn('domain');

      sut.visitImportDirective(directive);

      verifyInfoLoggedOnce();
      verifyNodeNeverReported();
    },
  );

  test(
    'When a relative import does not target the domain layer but its path is explicitly excluded in the configuration, the directive is ignored',
    () {
      final directive = parseValidImportDirective(
        "import 'core/models/auth_data.dart';",
      );
      givenImportUri(directive);

      when(() => mockDDRConfig.domainDirName).thenReturn('domain');
      when(() => mockDDRConfig.excludedProjectPaths).thenReturn(['core/']);

      sut.visitImportDirective(directive);

      verifyInfoLoggedOnce();
      verifyNodeNeverReported();
    },
  );

  test(
    'When a relative import does not target the domain layer and is not in an excluded project path, the directive is reported',
    () {
      final directive = parseValidImportDirective(
        "import 'feature/auth/data/sources/local_auth_data_source.dart';",
      );
      givenImportUri(directive);

      when(() => mockDDRConfig.domainDirName).thenReturn('domain');
      when(() => mockDDRConfig.excludedProjectPaths).thenReturn(['core/']);

      sut.visitImportDirective(directive);

      verifyInfoLoggedOnce();
      verifyNodeReportedOnce(directive);
    },
  );

  test(
    'When a package import targets the host package and points to a domain layer path, the directive is allowed',
    () {
      final directive = parseValidImportDirective(
        "import 'package:xyz/feature/auth/domain/services/auth_data_service.dart';",
      );
      givenImportUri(directive);

      when(() => mockDDRConfig.domainDirName).thenReturn('domain');
      when(() => mockPackageInfo.name).thenReturn('xyz');

      sut.visitImportDirective(directive);

      verifyInfoLoggedOnce();
      verifyNodeNeverReported();
    },
  );

  test(
    'When a package import targets the host package and its path is excluded by configuration, the directive is ignored',
    () {
      final directive = parseValidImportDirective(
        "import 'package:xyz/core/models/auth_data.dart';",
      );
      givenImportUri(directive);

      when(() => mockPackageInfo.name).thenReturn('xyz');
      when(() => mockDDRConfig.domainDirName).thenReturn('domain');
      when(() => mockDDRConfig.excludedProjectPaths).thenReturn(['core/']);

      sut.visitImportDirective(directive);

      verifyInfoLoggedOnce();
      verifyNodeNeverReported();
    },
  );

  test(
    'When a third party package import matches an excluded library prefix, the directive is ignored',
    () {
      final directive = parseValidImportDirective(
        "import 'package:dartz/functional/fold.dart';",
      );
      givenImportUri(directive);

      when(() => mockPackageInfo.name).thenReturn('xyz');
      when(() => mockDDRConfig.excludedLibraryPackages).thenReturn(['dartz']);

      sut.visitImportDirective(directive);

      verifyInfoLoggedOnce();
      verifyNodeNeverReported();
    },
  );

  test(
    'When a third party package import is not excluded by configuration, the directive is reported',
    () {
      final directive = parseValidImportDirective(
        "import 'package:dartz/functional/fold.dart';",
      );
      givenImportUri(directive);

      when(() => mockPackageInfo.name).thenReturn('xyz');
      when(() => mockDDRConfig.excludedLibraryPackages).thenReturn([]);

      sut.visitImportDirective(directive);

      verifyInfoLoggedOnce();
      verifyNodeReportedOnce(directive);
    },
  );
}
