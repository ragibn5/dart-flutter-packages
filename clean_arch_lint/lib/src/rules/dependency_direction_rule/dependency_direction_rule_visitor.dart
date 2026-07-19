import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_lint/src/models/clean_arch_lint_config.dart';
import 'package:clean_arch_lint/src/models/domain_unit_context.dart';
import 'package:clean_arch_lint/src/models/import_uri.dart';
import 'package:clean_arch_lint/src/services/import_uri_builder/import_uri_builder.dart';
import 'package:meta/meta.dart';

/// Visits import directives inside domain-layer files and reports violations.
///
/// This visitor is only registered for files that live inside a domain
/// directory (e.g. `lib/features/auth/domain/...`). It inspects every
/// import and decides whether it is allowed or not.
///
/// [ImportUri.path] is always a package-root-relative path
/// (starting with `lib/` or `test/`) thanks to [ImportUriBuilder]
/// resolving it at construction time.
///
/// Example project layout:
/// ```text
/// lib/
///   features/
///     auth/
///       domain/          <-- domain layer (guarded)
///         models/
///           auth_data.dart
///         services/
///           auth_service.dart
///       data/            <-- non-domain layer
///         repositories/
///           auth_repo_impl.dart
///     user_data/
///       domain/          <-- different feature's domain
///         models/
///           user_data.dart
/// ```
class DependencyDirectionRuleVisitor extends SimpleAstVisitor<void> {
  @visibleForTesting
  final AnalysisRule rule;

  @visibleForTesting
  final DomainUnitContext domainUnitContext;

  @visibleForTesting
  final RuleSessionContext<CleanArchLintConfig> sessionContext;

  final ImportUriBuilder _importUriBuilder;

  DependencyDirectionRuleVisitor(
    AnalysisRule rule,
    RuleSessionContext<CleanArchLintConfig> sessionContext,
    DomainUnitContext domainUnit,
  ) : this._(rule, domainUnit, sessionContext, ImportUriBuilder());

  @visibleForTesting
  DependencyDirectionRuleVisitor.test(
    AnalysisRule rule,
    RuleSessionContext<CleanArchLintConfig> sessionContext,
    ImportUriBuilder importUriBuilder, {
    String unitPath = 'lib/features/x/domain/a.dart',
    String domainDirPath = 'lib/features/x/domain/',
  }) : this._(
         rule,
         DomainUnitContext(unitPath, domainDirPath),
         sessionContext,
         importUriBuilder,
       );

  DependencyDirectionRuleVisitor._(
    this.rule,
    this.domainUnitContext,
    this.sessionContext,
    this._importUriBuilder,
  );

  @override
  void visitImportDirective(ImportDirective node) {
    final importUri = _importUriBuilder.fromImportNode(
      node,
      hostPath: domainUnitContext.unitPath,
    );

    if (importUri == null) {
      sessionContext.logger.logWarning(
        tag: '$DependencyDirectionRuleVisitor',
        message:
            'Ignoring import (invalid/unsupported): ${node.uri.stringValue}',
      );
      return;
    }

    // Dart SDK imports (e.g. dart:core, dart:async)
    if (importUri.scheme == 'dart') {
      _checkDartCoreImport(node, importUri);
      return;
    }

    // Own-package imports (no scheme = relative, or package:self/)
    if (importUri.scheme == null ||
        (importUri.scheme == 'package' &&
            importUri.packageName == sessionContext.config.packageInfo.name)) {
      _checkOwnPackageImport(node, importUri);
      return;
    }

    // Third-party package imports (e.g. 'package:dartz/dartz.dart')
    _checkLibraryPackageImport(node, importUri);
  }

  void _checkDartCoreImport(ImportDirective node, ImportUri importUri) {
    if (sessionContext.config.ddrConfig.excludeCoreDartPackages) {
      sessionContext.logger.logWarning(
        tag: '$DependencyDirectionRuleVisitor',
        message: 'Ignoring import (dart SDK): $importUri',
      );
      return;
    }

    rule.reportAtNode(node, arguments: ['core dart import in domain layer.']);
  }

  /// Checks own-package imports (relative and package:self/).
  ///
  /// At this point, the import path is always a package-root-relative path
  /// (e.g. `lib/feature/auth/domain/...`).
  ///
  /// The import is allowed if and only if it resolves to a file within
  /// [DomainUnitContext.domainDirPath] (same feature's domain) or an
  /// excluded project path.
  void _checkOwnPackageImport(ImportDirective node, ImportUri importUri) {
    // In the same domain.
    if (importUri.path.startsWith(
      domainUnitContext.domainDirPath.ensureTrailingPathSeparator,
    )) {
      sessionContext.logger.logWarning(
        tag: '$DependencyDirectionRuleVisitor',
        message: 'Ignoring import (same domain): $importUri',
      );
      return;
    }

    // Not in same domain.
    // Check excluded project paths.
    if (sessionContext.config.ddrConfig.excludedProjectPaths
        .map((p) => p.ensureTrailingPathSeparator)
        .any(importUri.path.startsWith)) {
      sessionContext.logger.logWarning(
        tag: '$DependencyDirectionRuleVisitor',
        message: 'Ignoring import (excluded project path): $importUri',
      );
      return;
    }

    rule.reportAtNode(
      node,
      arguments: ['not within the same domain.'],
    );
  }

  void _checkLibraryPackageImport(ImportDirective node, ImportUri importUri) {
    final importedPackage = importUri.packageName;
    if (importedPackage != null &&
        sessionContext.config.ddrConfig.excludedLibraryPackages.any(
          importedPackage.startsWith,
        )) {
      sessionContext.logger.logWarning(
        tag: '$DependencyDirectionRuleVisitor',
        message: 'Ignoring import (excluded package): $importUri',
      );
      return;
    }

    rule.reportAtNode(
      node,
      arguments: ['library package import in domain layer.'],
    );
  }
}
