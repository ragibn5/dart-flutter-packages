import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_lint/src/extensions/string_extensions.dart';
import 'package:clean_arch_lint/src/models/clean_arch_lint_config.dart';
import 'package:clean_arch_lint/src/models/import_uri.dart';
import 'package:clean_arch_lint/src/services/import_uri_builder/import_uri_builder.dart';
import 'package:meta/meta.dart';

class DependencyDirectionRuleVisitor extends SimpleAstVisitor<void> {
  @visibleForTesting
  final AnalysisRule rule;

  @visibleForTesting
  final RuleSessionContext<CleanArchLintConfig> sessionContext;

  final ImportUriBuilder _importUriBuilder;

  DependencyDirectionRuleVisitor(
    AnalysisRule rule,
    RuleSessionContext<CleanArchLintConfig> sessionContext,
  ) : this._(rule, sessionContext, ImportUriBuilder());

  @visibleForTesting
  DependencyDirectionRuleVisitor.test(
    AnalysisRule rule,
    RuleSessionContext<CleanArchLintConfig> sessionContext,
    ImportUriBuilder importUriBuilder,
  ) : this._(rule, sessionContext, importUriBuilder);

  DependencyDirectionRuleVisitor._(
    this.rule,
    this.sessionContext,
    this._importUriBuilder,
  );

  @override
  void visitImportDirective(ImportDirective node) {
    final importUri = _importUriBuilder.fromImportNode(node);
    if (importUri == null) {
      sessionContext.logger.logWarning(
        tag: '$DependencyDirectionRuleVisitor',
        message:
            'Invalid/Unsupported import uri (ignoring): ${node.uri.stringValue}',
      );
      return;
    }

    if (importUri.scheme == 'dart') {
      _checkDartCoreImport(node, importUri);
      return;
    }

    if (importUri.scheme == null) {
      _checkOwnPackageImport(node, importUri);
      return;
    }

    if (importUri.scheme == 'package' &&
        importUri.packageName == sessionContext.config.packageInfo.name) {
      _checkOwnPackageImport(node, importUri);
      return;
    }

    _checkLibraryPackageImport(node, importUri);
  }

  void _checkDartCoreImport(ImportDirective node, ImportUri importUri) {
    if (sessionContext.config.ddrConfig.excludeCoreDartPackages) {
      sessionContext.logger.logWarning(
        tag: '$DependencyDirectionRuleVisitor',
        message: 'Core dart import (ignoring): $importUri',
      );
      return;
    }

    rule.reportAtNode(node, arguments: ['core dart import in domain layer.']);
  }

  void _checkOwnPackageImport(ImportDirective node, ImportUri importUri) {
    final domainPathSegment = sessionContext.config.ddrConfig.domainDirName
        .surroundingPathSeparator();
    if (importUri.path.contains(domainPathSegment)) {
      sessionContext.logger.logWarning(
        tag: '$DependencyDirectionRuleVisitor',
        message: 'Domain import (ignoring): $importUri',
      );
      return;
    }

    if (sessionContext.config.ddrConfig.excludedProjectPaths.any(
      importUri.path.startsWith,
    )) {
      sessionContext.logger.logWarning(
        tag: '$DependencyDirectionRuleVisitor',
        message: 'Excluded project import (ignoring): $importUri',
      );
      return;
    }

    rule.reportAtNode(node, arguments: ['non-domain import in domain layer.']);
  }

  void _checkLibraryPackageImport(ImportDirective node, ImportUri importUri) {
    final importedPackage = importUri.packageName;
    if (importedPackage != null &&
        sessionContext.config.ddrConfig.excludedLibraryPackages.any(
          importedPackage.startsWith,
        )) {
      sessionContext.logger.logWarning(
        tag: '$DependencyDirectionRuleVisitor',
        message: 'Excluded package import (ignoring): $importUri',
      );
      return;
    }

    rule.reportAtNode(
      node,
      arguments: ['library package import in domain layer.'],
    );
  }
}
