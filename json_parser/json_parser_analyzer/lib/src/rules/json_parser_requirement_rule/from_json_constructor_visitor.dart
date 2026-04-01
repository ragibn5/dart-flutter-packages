// ignore_for_file: lines_longer_than_80_chars

import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:json_parser_analyzer/src/models/json_parser_analyzer_config.dart';
import 'package:meta/meta.dart';

class FromJsonConstructorVisitorConfig {
  final String wrongParamCountContextMessage;
  final String wrongParamDeclarationTypeContextMessage;
  final String invalidParamTypeContextMessage;

  FromJsonConstructorVisitorConfig({
    this.wrongParamCountContextMessage =
        'fromJson constructor must have only one positional parameter of type Map<String, dynamic> or Map<String, Object?>.',
    this.wrongParamDeclarationTypeContextMessage =
        'fromJson constructor must have only one positional parameter of type Map<String, dynamic> or Map<String, Object?>.',
    this.invalidParamTypeContextMessage =
        'fromJson constructor must have only one positional parameter of type Map<String, dynamic> or Map<String, Object?>.',
  });
}

class FromJsonConstructorVisitor {
  @visibleForTesting
  final AnalysisRule rule;

  @visibleForTesting
  final FromJsonConstructorVisitorConfig visitorConfig;

  @visibleForTesting
  final RuleSessionContext<JsonParserAnalyzerConfig> sessionContext;

  final CollectionTypeResolver _collectionTypeResolver;

  FromJsonConstructorVisitor(
    AnalysisRule rule,
    RuleSessionContext<JsonParserAnalyzerConfig> sessionContext,
  ) : this._(
        rule,
        FromJsonConstructorVisitorConfig(),
        sessionContext,
        CollectionTypeResolverFactory.create(),
      );

  @visibleForTesting
  FromJsonConstructorVisitor.test(
    AnalysisRule rule,
    FromJsonConstructorVisitorConfig visitorConfig,
    RuleSessionContext<JsonParserAnalyzerConfig> sessionContext,
    CollectionTypeResolver collectionTypeResolver,
  ) : this._(rule, visitorConfig, sessionContext, collectionTypeResolver);

  FromJsonConstructorVisitor._(
    this.rule,
    this.visitorConfig,
    this.sessionContext,
    this._collectionTypeResolver,
  );

  void visit(ConstructorDeclaration fromJsonConstructor) {
    final params = fromJsonConstructor.parameters.parameters;
    if (params.length != 1) {
      rule.reportAtNode(
        fromJsonConstructor.parameters,
        arguments: [visitorConfig.wrongParamCountContextMessage],
      );

      // This check should hide other param specific checks,
      // because we need to have right number of parameters
      // to begin with. So, will return.
      return;
    }

    if (!_isValidParam(params.first)) {
      rule.reportAtNode(
        params.owner,
        arguments: [visitorConfig.wrongParamDeclarationTypeContextMessage],
      );

      // This check should hide other param specific checks,
      // because we need to have right parameter declaration
      // type to begin with. So, will return.
      return;
    }

    final paramType = _parameterType(params.first);
    if (!_isJsonMap(paramType)) {
      rule.reportAtNode(
        paramType,
        arguments: [visitorConfig.invalidParamTypeContextMessage],
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

  bool _isValidParam(FormalParameter param) {
    return param.isPositional &&
        param is! FieldFormalParameter &&
        param is! SuperFormalParameter;
  }

  TypeAnnotation? _parameterType(FormalParameter param) {
    final actual = param is DefaultFormalParameter ? param.parameter : param;
    return switch (actual) {
      final SimpleFormalParameter p => p.type,
      final FieldFormalParameter p => p.type,
      final SuperFormalParameter p => p.type,
      _ => null,
    };
  }
}
