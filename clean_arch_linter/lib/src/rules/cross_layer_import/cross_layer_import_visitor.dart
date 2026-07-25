import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_linter/src/models/clean_arch_linter_config.dart';
import 'package:clean_arch_linter/src/models/domain_unit_context.dart';
import 'package:clean_arch_linter/src/models/import_uri.dart';
import 'package:clean_arch_linter/src/services/import_uri_builder/import_uri_builder.dart';
import 'package:meta/meta.dart';

class CrossLayerImportVisitor extends SimpleAstVisitor<void> {
  @visibleForTesting
  final AnalysisRule rule;

  @visibleForTesting
  final DomainUnitContext domainUnitContext;

  @visibleForTesting
  final RuleSessionContext<CleanArchLinterConfig> sessionContext;

  final ImportUriBuilder _importUriBuilder;

  CrossLayerImportVisitor(
    this.rule,
    this.domainUnitContext,
    this.sessionContext, {
    @visibleForTesting ImportUriBuilder? importUriBuilder,
  }) : _importUriBuilder = importUriBuilder ?? ImportUriBuilder();

  @override
  void visitImportDirective(ImportDirective node) {
    final importUri = _importUriBuilder.fromImportNode(
      node,
      hostPath: domainUnitContext.unitPath,
    );

    // Invalid import
    if (importUri == null) {
      sessionContext.logger.logInfo(
        tag: '$CrossLayerImportVisitor',
        message: 'Ignoring import (invalid import node): $node',
      );
      return;
    }

    // Only check own-package imports (relative or package:self/)
    if (!_isSamePackageImport(importUri)) {
      sessionContext.logger.logInfo(
        tag: '$CrossLayerImportVisitor',
        message: 'Ignoring import (not a self package import): $node',
      );
      return;
    }

    // Same domain is always allowed.
    if (_isSameDomainImport(importUri)) {
      sessionContext.logger.logInfo(
        tag: '$CrossLayerImportVisitor',
        message: 'Ignoring import (same domain): $importUri',
      );
      return;
    }

    // Check excluded project paths.
    if (_isExcludedProjectPath(importUri)) {
      sessionContext.logger.logInfo(
        tag: '$CrossLayerImportVisitor',
        message: 'Ignoring import (excluded project path): $importUri',
      );
      return;
    }

    rule.reportAtNode(node, arguments: ['non-domain import in domain layer.']);
  }

  bool _isSamePackageImport(ImportUri importUri) {
    return importUri.scheme == null ||
        (importUri.scheme == 'package' &&
            importUri.packageName == sessionContext.config.packageInfo.name);
  }

  bool _isSameDomainImport(ImportUri importUri) {
    return importUri.path.startsWith(
      domainUnitContext.domainDirPath
          .normalizePathSeparators(pathSeparator: '/')
          .ensureTrailingPathSeparator(pathSeparator: '/'),
    );
  }

  bool _isExcludedProjectPath(ImportUri importUri) {
    return sessionContext.config.crossLayerConfig.excludedProjectPaths
        .map(
          (p) => p
              .normalizePathSeparators(pathSeparator: '/')
              .ensureTrailingPathSeparator(pathSeparator: '/'),
        )
        .any(importUri.path.startsWith);
  }
}
