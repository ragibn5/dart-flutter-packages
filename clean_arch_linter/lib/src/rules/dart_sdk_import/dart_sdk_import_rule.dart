import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:clean_arch_linter/src/models/clean_arch_linter_config.dart';
import 'package:clean_arch_linter/src/models/domain_unit_context.dart';
import 'package:clean_arch_linter/src/rules/dart_sdk_import/dart_sdk_import_visitor.dart';
import 'package:clean_arch_linter/src/services/domain_dir_path_resolver/domain_dir_path_resolver.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

class DartSDKImportRule
    extends SessionManagedAnalysisRule<CleanArchLinterConfig> {
  static const LintCode lintCode = LintCode(
    'dart_sdk_import',
    'External Dart library import in domain component: {0}',
    correctionMessage:
        'Prefer keeping the domain self sufficient. '
        'Common libraries (e.g. dart:core, dart:async) are fine and expected. '
        'Allow via excluded_dart_packages if needed.',
    severity: DiagnosticSeverity.WARNING,
  );

  final DomainDirPathResolver _domainDirPathResolver;

  DartSDKImportRule(
    SessionDataManager sessionDataManager, {
    @visibleForTesting DomainDirPathResolver? domainDirPathResolver,
  }) : _domainDirPathResolver =
           domainDirPathResolver ?? DomainDirPathResolver(),
       super(
         RuleMetadata(lintCode.name, lintCode.problemMessage),
         sessionDataManager,
       );

  @override
  DiagnosticCode get diagnosticCode => lintCode;

  @override
  void registerSessionedNodeProcessors(
    RuleContext context,
    RuleVisitorRegistry registry,
    RuleSessionContext<CleanArchLinterConfig> sessionContext,
  ) {
    final pkgRelativeUnitPath = context.packageRelativeUnitPath(
      pathSeparator: '/',
    );
    if (pkgRelativeUnitPath == null) {
      final absUnitPath = context.definingUnit.file.path
          .normalizePathSeparators(pathSeparator: path.separator);
      sessionContext.logger.logInfo(
        tag: '$DartSDKImportRule',
        message: 'Skipping unit (no package root): $absUnitPath',
      );
      return;
    }

    final domainDirPath = _domainDirPathResolver.findDomainDirPath(
      pkgRelativeUnitPath,
      sessionContext.config.domainConfig.domainDirNames,
    );
    if (domainDirPath == null) {
      sessionContext.logger.logInfo(
        tag: '$DartSDKImportRule',
        message: 'Skipping unit (not a domain component): $pkgRelativeUnitPath',
      );
      return;
    }

    registry.addImportDirective(
      this,
      DartSDKImportVisitor(
        this,
        DomainUnitContext(pkgRelativeUnitPath, domainDirPath),
        sessionContext,
      ),
    );
  }
}
