import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:clean_arch_lint/src/extensions/string_extensions.dart';
import 'package:clean_arch_lint/src/models/clean_arch_lint_config.dart';
import 'package:clean_arch_lint/src/models/import_uri.dart';
import 'package:meta/meta.dart';

class DependencyDirectionRuleVisitor extends SimpleAstVisitor<void> {
  @visibleForTesting
  final AnalysisRule rule;

  @visibleForTesting
  final RuleSessionContext<CleanArchLintConfig> sessionContext;

  DependencyDirectionRuleVisitor(this.rule, this.sessionContext);

  @override
  void visitImportDirective(ImportDirective node) {
    final importUriString = node.uri.stringValue;
    if (importUriString == null) {
      sessionContext.logger.logInfo(
        tag: '$DependencyDirectionRuleVisitor',
        message: 'Invalid import uri (ignoring): $importUriString',
      );
      return;
    }

    final importUri = ImportUri.fromImportNode(node);
    if (importUri == null) {
      sessionContext.logger.logInfo(
        tag: '$DependencyDirectionRuleVisitor',
        message: 'Unsupported import uri (ignoring): $importUriString',
      );
      return;
    }

    if (_shouldReportImport(importUri)) {
      rule.reportAtNode(node);
    }
  }

  bool _shouldReportDartCoreImport(ImportUri importUri) {
    if (sessionContext.config.ddrConfig.excludeCoreDartPackages) {
      sessionContext.logger.logInfo(
        tag: '$DependencyDirectionRuleVisitor',
        message: 'Core dart import (ignoring): $importUri',
      );
      return false;
    }

    sessionContext.logger.logInfo(
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
        importUri.packageName == sessionContext.config.packageInfo.name) {
      return _shouldReportOwnPackageImport(importUri);
    }

    return _shouldReportLibraryPackageImport(importUri);
  }

  bool _shouldReportOwnPackageImport(ImportUri importUri) {
    final domainPathSegment = sessionContext.config.ddrConfig.domainDirName
        .surroundingPathSeparator();
    if (importUri.path.contains(domainPathSegment)) {
      sessionContext.logger.logInfo(
        tag: '$DependencyDirectionRuleVisitor',
        message: 'Domain import (ignoring): $importUri',
      );
      return false;
    }

    if (sessionContext.config.ddrConfig.excludedProjectPaths.any(
      importUri.path.startsWith,
    )) {
      sessionContext.logger.logInfo(
        tag: '$DependencyDirectionRuleVisitor',
        message: 'Excluded project import (ignoring): $importUri',
      );
      return false;
    }

    sessionContext.logger.logInfo(
      tag: '$DependencyDirectionRuleVisitor',
      message: 'Reporting non-domain import: $importUri',
    );

    return true;
  }

  bool _shouldReportLibraryPackageImport(ImportUri importUri) {
    final importedPackage = importUri.packageName;
    if (importedPackage != null &&
        sessionContext.config.ddrConfig.excludedLibraryPackages.any(
          importedPackage.startsWith,
        )) {
      sessionContext.logger.logInfo(
        tag: '$DependencyDirectionRuleVisitor',
        message: 'Excluded package import (ignoring): $importUri',
      );
      return false;
    }

    sessionContext.logger.logInfo(
      tag: '$DependencyDirectionRuleVisitor',
      message: 'Reporting package import: $importUri',
    );

    return true;
  }
}
