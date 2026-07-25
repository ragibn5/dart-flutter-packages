import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_linter/src/models/clean_arch_linter_config.dart';
import 'package:clean_arch_linter/src/models/domain_unit_context.dart';
import 'package:clean_arch_linter/src/services/import_uri_builder/import_uri_builder.dart';
import 'package:meta/meta.dart';

class DartSDKImportVisitor extends SimpleAstVisitor<void> {
  @visibleForTesting
  final AnalysisRule rule;

  @visibleForTesting
  final DomainUnitContext domainUnitContext;

  @visibleForTesting
  final RuleSessionContext<CleanArchLinterConfig> sessionContext;

  final ImportUriBuilder _importUriBuilder;

  DartSDKImportVisitor(
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
        tag: '$DartSDKImportVisitor',
        message: 'Ignoring import (invalid import node): $node',
      );
      return;
    }

    if (importUri.scheme != 'dart') {
      sessionContext.logger.logInfo(
        tag: '$DartSDKImportVisitor',
        message: 'Ignoring import (not a dart SDK import): $importUri',
      );
      return;
    }

    if (sessionContext.config.dartSDKConfig.excludedDartPackages.any(
      importUri.path.startsWith,
    )) {
      sessionContext.logger.logInfo(
        tag: '$DartSDKImportVisitor',
        message: 'Ignoring import (excluded dart package): $importUri',
      );
      return;
    }

    rule.reportAtNode(node, arguments: ['core dart import in domain layer.']);
  }
}
