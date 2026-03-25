import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:clean_arch_lint/src/plugins/clean_arch_lint_plugin.dart';
import 'package:clean_arch_lint/src/services/config/clean_arch_lint_config_loader.dart';

/// The plugin entry point.
///
/// The Dart Analysis Server looks for a top-level field named `plugin`.
/// So, DO NOT change the variable name. See this doc for more information:
/// https://dart.dev/tools/analyzer-plugins.
final plugin = CleanArchLintPlugin(
  SessionDataManager.createNewInstance(CleanArchLintConfigLoader()),
);
