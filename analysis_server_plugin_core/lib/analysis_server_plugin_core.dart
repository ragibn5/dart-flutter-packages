/// Core components to build a custom Dart analysis server plugin.
library;

export 'package:analysis_server_plugin/plugin.dart';
export 'package:analysis_server_plugin/registry.dart';
export 'package:analyzer/analysis_rule/analysis_rule.dart';
export 'package:analyzer/analysis_rule/rule_context.dart';
export 'package:analyzer/analysis_rule/rule_visitor_registry.dart';
export 'package:analyzer/dart/analysis/utilities.dart';
export 'package:analyzer/dart/ast/ast.dart';
export 'package:analyzer/dart/ast/visitor.dart';
export 'package:analyzer/error/error.dart';
export 'package:analyzer/workspace/workspace.dart';

export 'src/extensions/path_string_extensions.dart';
export 'src/extensions/rule_context_extensions.dart';
export 'src/models/context_config.dart';
export 'src/models/log_config.dart';
export 'src/models/package_info.dart';
export 'src/models/rule_metadata.dart';
export 'src/models/rule_session_context.dart';
export 'src/models/scan_config.dart';
export 'src/rules/session_managed_analysis_rule.dart';
export 'src/services/config/context_config_loader.dart';
export 'src/services/logger/session_logger.dart';
export 'src/services/resolvers/type_resolvers/annotation_type_resolver.dart';
export 'src/services/resolvers/type_resolvers/annotation_type_resolver_factory.dart';
export 'src/services/resolvers/type_resolvers/collection_type_resolver.dart';
export 'src/services/resolvers/type_resolvers/collection_type_resolver_factory.dart';
export 'src/services/session/session_data_manager.dart';
export 'src/services/session/session_data_manager_factory.dart';
export 'src/typedefs/typedefs.dart';
