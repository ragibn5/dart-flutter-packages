import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:clean_arch_lint/src/extensions/string_extensions.dart';
import 'package:clean_arch_lint/src/models/clean_arch_lint_config.dart';
import 'package:clean_arch_lint/src/models/import_uri.dart';

class DependencyDirectionRule
    extends SessionManagedAnalysisRule<CleanArchLintConfig> {
  static const LintCode DDR_LINT_CODE = LintCode(
    'clean_arch_dependency_direction',
    'Invalid dependency direction found in domain component.',
    correctionMessage: '''
    Domain components should be as self-sufficient as possible.
  
    If you need to use an external dependency anyway (which should be
    approved by tech leads), you can allow it through the configuration
    file. Please refer to the documentation for more details.
    ''',
    hasPublishedDocs: true,
  );

  DependencyDirectionRule(SessionDataManager sessionDataManager)
    : super(
        RuleMetadata(DDR_LINT_CODE.name, DDR_LINT_CODE.problemMessage),
        sessionDataManager,
      );

  @override
  DiagnosticCode get diagnosticCode => DDR_LINT_CODE;

  @override
  void registerPackageNodeProcessors(
    RuleContext context,
    RuleVisitorRegistry registry,
    RuleSessionContext<CleanArchLintConfig> sessionContext,
  ) {
    final srcPath = context.definingUnit.file.path;

    final ddrConfig = sessionContext.config.ddrConfig;
    if (!srcPath.contains(ddrConfig.domainDirName.surroundingPathSeparator())) {
      sessionContext.logger.logInfo(
        tag: '$DependencyDirectionRule',
        message: 'Ignoring non domain component: $srcPath',
      );
      return;
    }

    sessionContext.logger.logInfo(
      tag: '$DependencyDirectionRule',
      message: 'Registering $DependencyDirectionRuleVisitor for: $srcPath',
    );

    registry.addImportDirective(
      this,
      DependencyDirectionRuleVisitor(this, sessionContext),
    );
  }
}

class DependencyDirectionRuleVisitor extends SimpleAstVisitor<void> {
  final AnalysisRule _rule;
  final RuleSessionContext<CleanArchLintConfig> _sessionContext;

  DependencyDirectionRuleVisitor(this._rule, this._sessionContext);

  @override
  void visitImportDirective(ImportDirective node) {
    final importUriString = node.uri.stringValue;
    if (importUriString == null) {
      _sessionContext.logger.logInfo(
        tag: '$DependencyDirectionRuleVisitor',
        message: 'Invalid import uri (ignoring): $importUriString',
      );
      return;
    }

    final importUri = ImportUri.fromImportNode(node);
    if (importUri == null) {
      _sessionContext.logger.logInfo(
        tag: '$DependencyDirectionRuleVisitor',
        message: 'Unsupported import uri (ignoring): $importUriString',
      );
      return;
    }

    if (_shouldReportImport(importUri)) {
      _rule.reportAtNode(node);
    }
  }

  bool _shouldReportDartCoreImport(ImportUri importUri) {
    if (_sessionContext.config.ddrConfig.excludeCoreDartPackages) {
      _sessionContext.logger.logInfo(
        tag: '$DependencyDirectionRuleVisitor',
        message: 'Core dart import (ignoring): $importUri',
      );
      return false;
    }

    _sessionContext.logger.logInfo(
      tag: '$DependencyDirectionRuleVisitor',
      message: 'Reporting non-domain core dart import: $importUri',
    );

    return true;
  }

  bool _shouldReportImport(ImportUri importUri) {
    // Dart core imports
    if (importUri.scheme == 'dart') {
      return _shouldReportDartCoreImport(importUri);
    }

    // If scheme is null, it is a relative import.
    // And relative imports are always from the main host package.
    if (importUri.scheme == null) {
      return _shouldReportOwnPackageImport(importUri);
    }

    // If scheme is `package` and package name is the
    // session context's package name, it is the main host package.
    if (importUri.scheme == 'package' &&
        importUri.packageName == _sessionContext.config.packageInfo.name) {
      return _shouldReportOwnPackageImport(importUri);
    }

    return _shouldReportLibraryPackageImport(importUri);
  }

  bool _shouldReportOwnPackageImport(ImportUri importUri) {
    final domainPathSegment = _sessionContext.config.ddrConfig.domainDirName
        .surroundingPathSeparator();
    if (importUri.path.contains(domainPathSegment)) {
      _sessionContext.logger.logInfo(
        tag: '$DependencyDirectionRuleVisitor',
        message: 'Domain import (ignoring): $importUri',
      );
      return false;
    }

    if (_sessionContext.config.ddrConfig.excludedProjectPaths.any(
      importUri.path.startsWith,
    )) {
      _sessionContext.logger.logInfo(
        tag: '$DependencyDirectionRuleVisitor',
        message: 'Excluded project import (ignoring): $importUri',
      );
      return false;
    }

    _sessionContext.logger.logInfo(
      tag: '$DependencyDirectionRuleVisitor',
      message: 'Reporting non-domain import: $importUri',
    );

    return true;
  }

  bool _shouldReportLibraryPackageImport(ImportUri importUri) {
    final importedPackage = importUri.packageName;
    if (importedPackage != null &&
        _sessionContext.config.ddrConfig.excludedLibraryPackages.any(
          importedPackage.startsWith,
        )) {
      _sessionContext.logger.logInfo(
        tag: '$DependencyDirectionRuleVisitor',
        message: 'Excluded package import (ignoring): $importUri',
      );
      return false;
    }

    _sessionContext.logger.logInfo(
      tag: '$DependencyDirectionRuleVisitor',
      message: 'Reporting package import: $importUri',
    );

    return true;
  }
}
