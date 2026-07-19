import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_lint/src/extensions/string_extensions.dart';
import 'package:clean_arch_lint/src/models/clean_arch_lint_config.dart';
import 'package:clean_arch_lint/src/models/domain_unit_context.dart';
import 'package:clean_arch_lint/src/rules/dependency_direction_rule/dependency_direction_rule_visitor.dart';

class DependencyDirectionRule
    extends SessionManagedAnalysisRule<CleanArchLintConfig> {
  static const LintCode DDR_LINT_CODE = LintCode(
    'clean_arch_dependency_direction',
    'Inappropriate dependency in domain component: {0}',
    correctionMessage: '''
    Domain components should be as self-sufficient as possible.
  
    If you need to use an external dependency anyway (which should be
    approved by tech leads), you can allow it through the configuration
    file. Please refer to the documentation for more details.
    ''',
    severity: DiagnosticSeverity.WARNING,
  );

  DependencyDirectionRule(SessionDataManager sessionDataManager)
    : super(
        RuleMetadata(DDR_LINT_CODE.name, DDR_LINT_CODE.problemMessage),
        sessionDataManager,
      );

  @override
  DiagnosticCode get diagnosticCode => DDR_LINT_CODE;

  @override
  void registerSessionedNodeProcessors(
    RuleContext context,
    RuleVisitorRegistry registry,
    RuleSessionContext<CleanArchLintConfig> sessionContext,
  ) {
    final packageRoot = context.package?.root.path;
    final absPathOfUnit = context.definingUnit.file.path;

    if (packageRoot == null) {
      sessionContext.logger.logInfo(
        tag: '$DependencyDirectionRule',
        message: 'Skipping unit (no package root): $absPathOfUnit',
      );
      return;
    }

    final ddrConfig = sessionContext.config.ddrConfig;
    final unitPath = _toPackageRelativePath(absPathOfUnit, packageRoot);
    final domainDirPath = _findDomainDirPath(
      unitPath,
      ddrConfig.domainDirNames,
    );

    if (domainDirPath == null) {
      sessionContext.logger.logInfo(
        tag: '$DependencyDirectionRule',
        message: 'Skipping unit (not a domain component): $unitPath',
      );
      return;
    }

    sessionContext.logger.logInfo(
      tag: '$DependencyDirectionRule',
      message: 'Registering visitor for unit: $unitPath',
    );

    registry.addImportDirective(
      this,
      DependencyDirectionRuleVisitor(
        this,
        sessionContext,
        DomainUnitContext(unitPath, domainDirPath),
      ),
    );
  }

  /// Converts an absolute file-system path to a package-root-relative path.
  ///
  /// e.g. `/Users/.../app_template/lib/features/app/domain/service.dart`
  ///   → `lib/features/app/domain/service.dart`
  String _toPackageRelativePath(String absolutePath, String packageRoot) {
    // packageRoot may or may not end with a separator.
    final prefix = packageRoot.endsWith('/') ? packageRoot : '$packageRoot/';
    return absolutePath.substring(prefix.length).replaceAll(r'\', '/');
  }

  /// Finds the domain directory path within [hostUnitPath].
  ///
  /// Returns the package-root-relative path of the domain directory,
  /// or `null` if the file is not inside any domain directory. For example,
  /// if [hostUnitPath] is `lib/feature/auth/domain/services/auth_service.dart`,
  /// and [domainDirNames] is `['domain']`, this method returns `lib/feature/auth/domain/`.
  String? _findDomainDirPath(String hostUnitPath, List<String> domainDirNames) {
    for (final name in domainDirNames) {
      final segment = name.surroundingPathSeparator();
      final idx = hostUnitPath.lastIndexOf(segment);
      if (idx != -1) {
        return hostUnitPath.substring(0, idx + segment.length);
      }
    }
    return null;
  }
}
