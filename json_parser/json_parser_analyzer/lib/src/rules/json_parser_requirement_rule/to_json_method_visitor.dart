// ignore_for_file: lines_longer_than_80_chars

import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:json_parser_analyzer/src/models/json_parser_analyzer_config.dart';
import 'package:meta/meta.dart';

class ToJsonMethodVisitorConfig {
  final String getterNotAllowedContextMessage;
  final String paramsNotAllowedContextMessage;
  final String missingReturnTypeContextMessage;
  final String invalidReturnTypeContextMessage;

  ToJsonMethodVisitorConfig({
    this.getterNotAllowedContextMessage = 'toJson method must not be a getter.',
    this.paramsNotAllowedContextMessage =
        'toJson method must not have parameters.',
    this.missingReturnTypeContextMessage =
        'toJson method must have an explicit return type.',
    this.invalidReturnTypeContextMessage =
        'toJson method must return Map<String, dynamic> or Map<String, Object?>.',
  });
}

class ToJsonMethodVisitor {
  @visibleForTesting
  final AnalysisRule rule;

  @visibleForTesting
  final ToJsonMethodVisitorConfig visitorConfig;

  @visibleForTesting
  final RuleSessionContext<JsonParserAnalyzerConfig> sessionContext;

  final CollectionTypeResolver _collectionTypeResolver;

  ToJsonMethodVisitor(
    AnalysisRule rule,
    RuleSessionContext<JsonParserAnalyzerConfig> sessionContext,
  ) : this._(
        rule,
        ToJsonMethodVisitorConfig(),
        sessionContext,
        CollectionTypeResolverFactory.create(),
      );

  @visibleForTesting
  ToJsonMethodVisitor.test(
    AnalysisRule rule,
    ToJsonMethodVisitorConfig visitorConfig,
    RuleSessionContext<JsonParserAnalyzerConfig> sessionContext,
    CollectionTypeResolver collectionTypeResolver,
  ) : this._(rule, visitorConfig, sessionContext, collectionTypeResolver);

  ToJsonMethodVisitor._(
    this.rule,
    this.visitorConfig,
    this.sessionContext,
    this._collectionTypeResolver,
  );

  void visit(MethodDeclaration toJsonMethod) {
    if (toJsonMethod.isGetter) {
      rule.reportAtToken(
        toJsonMethod.name,
        arguments: [visitorConfig.getterNotAllowedContextMessage],
      );

      // If it is a getter, no other checks needed.
      // So, will return.
      return;
    }

    final params = toJsonMethod.parameters?.parameters ?? [];
    if (params.isNotEmpty) {
      rule.reportAtNode(
        toJsonMethod.parameters,
        arguments: [visitorConfig.paramsNotAllowedContextMessage],
      );
    }

    final returnType = toJsonMethod.returnType;
    if (returnType == null) {
      rule.reportAtToken(
        toJsonMethod.name,
        arguments: [visitorConfig.missingReturnTypeContextMessage],
      );

      // If the return type was not declared, checks related
      // to return type's type is irrelevant. So, will return.
      return;
    }

    if (!_isJsonMap(returnType)) {
      rule.reportAtNode(
        returnType,
        arguments: [visitorConfig.invalidReturnTypeContextMessage],
      );
    }
  }

  bool _isJsonMap(TypeAnnotation? typeAnnotation) {
    if (typeAnnotation == null) {
      return false;
    }

    final isDynamicValueTypedJsonMap = _collectionTypeResolver.isMapOf(
      typeAnnotation,
      keyType: 'String',
      valueType: 'dynamic',
    );

    final isObjectValueTypedJsonMap = _collectionTypeResolver.isMapOf(
      typeAnnotation,
      keyType: 'String',
      valueType: 'Object?',
    );

    return isObjectValueTypedJsonMap || isDynamicValueTypedJsonMap;
  }
}
