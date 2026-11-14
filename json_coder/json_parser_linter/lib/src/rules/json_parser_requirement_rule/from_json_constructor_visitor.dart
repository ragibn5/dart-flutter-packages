// ignore_for_file: lines_longer_than_80_chars

import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:json_parser_linter/src/models/json_parser_linter_config.dart';
import 'package:meta/meta.dart';

class FromJsonConstructorVisitorConfig {
  final String wrongParamCountContextMessage;
  final String wrongParamDeclarationTypeContextMessage;
  final String invalidParamTypeContextMessage;

  FromJsonConstructorVisitorConfig({
    this.wrongParamCountContextMessage =
        'fromJson constructor must take exactly one parameter',
    this.wrongParamDeclarationTypeContextMessage =
        'fromJson constructor parameter must be a normal positional parameter',
    this.invalidParamTypeContextMessage =
        'fromJson constructor parameter must be '
        'Map<String, dynamic> or Map<String, Object?>',
  });
}

class FromJsonConstructorVisitor {
  @visibleForTesting
  final AnalysisRule rule;

  @visibleForTesting
  final FromJsonConstructorVisitorConfig visitorConfig;

  @visibleForTesting
  final RuleSessionContext<JsonParserLinterConfig> sessionContext;

  final CollectionTypeResolver _collectionTypeResolver;

  FromJsonConstructorVisitor(
    this.rule,
    this.sessionContext, {
    @visibleForTesting FromJsonConstructorVisitorConfig? visitorConfig,
    @visibleForTesting CollectionTypeResolver? collectionTypeResolver,
  }) : visitorConfig = visitorConfig ?? FromJsonConstructorVisitorConfig(),
       _collectionTypeResolver =
           collectionTypeResolver ?? CollectionTypeResolverFactory.create();

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
    // An optional parameter, such as `[this.json]`, comes wrapped.
    final actual = param is DefaultFormalParameter ? param.parameter : param;
    return param.isPositional &&
        actual is! FieldFormalParameter &&
        actual is! SuperFormalParameter;
  }

  TypeAnnotation? _parameterType(FormalParameter param) {
    final actual = param is DefaultFormalParameter ? param.parameter : param;
    return switch (actual) {
      final SimpleFormalParameter p => p.type,
      _ => null,
    };
  }
}
