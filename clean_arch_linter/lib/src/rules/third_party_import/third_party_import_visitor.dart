import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_linter/src/models/clean_arch_linter_config.dart';
import 'package:clean_arch_linter/src/models/domain_unit_context.dart';
import 'package:clean_arch_linter/src/models/import_uri.dart';
import 'package:clean_arch_linter/src/services/import_uri_builder/import_uri_builder.dart';
import 'package:meta/meta.dart';

class ThirdPartyImportVisitorConfig {
  final String contextMessage;

  ThirdPartyImportVisitorConfig({
    this.contextMessage = 'library package import in domain layer.',
  });
}

class ThirdPartyImportVisitor extends SimpleAstVisitor<void> {
  @visibleForTesting
  final AnalysisRule rule;

  @visibleForTesting
  final DomainUnitContext domainUnitContext;

  @visibleForTesting
  final RuleSessionContext<CleanArchLinterConfig> sessionContext;

  final ThirdPartyImportVisitorConfig _visitorConfig;

  final ImportUriBuilder _importUriBuilder;

  ThirdPartyImportVisitor(
    this.rule,
    this.domainUnitContext,
    this.sessionContext, {
    @visibleForTesting ThirdPartyImportVisitorConfig? visitorConfig,
    @visibleForTesting ImportUriBuilder? importUriBuilder,
  }) : _visitorConfig = visitorConfig ?? ThirdPartyImportVisitorConfig(),
       _importUriBuilder = importUriBuilder ?? ImportUriBuilder();

  @override
  void visitImportDirective(ImportDirective node) {
    final importUri = _importUriBuilder.fromImportNode(
      node,
      hostPath: domainUnitContext.unitPath,
    );

    // Invalid import
    if (importUri == null) {
      sessionContext.logger.logInfo(
        tag: '$ThirdPartyImportVisitor',
        message: 'Ignoring import (invalid import node): $node',
      );
      return;
    }

    // Only check third-party package imports.
    if (importUri.scheme != 'package') {
      sessionContext.logger.logInfo(
        tag: '$ThirdPartyImportVisitor',
        message: 'Ignoring import (non-third party package import): $node',
      );
      return;
    }

    // Skip own-package imports.
    if (importUri.packageName == sessionContext.config.packageInfo.name) {
      sessionContext.logger.logInfo(
        tag: '$ThirdPartyImportVisitor',
        message: 'Ignoring import (own-package import): $importUri',
      );
      return;
    }

    // Check excluded packages.
    if (_isExcludedPackage(importUri)) {
      sessionContext.logger.logInfo(
        tag: '$ThirdPartyImportVisitor',
        message: 'Ignoring import (excluded package): $importUri',
      );
      return;
    }

    rule.reportAtNode(node, arguments: [_visitorConfig.contextMessage]);
  }

  bool _isExcludedPackage(ImportUri importUri) {
    final packageName = importUri.packageName;
    return packageName != null &&
        sessionContext.config.thirdPartyConfig.excludedLibraryPackages.any(
          packageName.startsWith,
        );
  }
}
