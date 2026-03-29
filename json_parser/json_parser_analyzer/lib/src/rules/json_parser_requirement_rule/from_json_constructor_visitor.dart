// ignore_for_file: lines_longer_than_80_chars

import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:json_parser_analyzer/src/models/json_parser_analyzer_config.dart';
import 'package:meta/meta.dart';

class FromJsonConstructorVisitor {
  @visibleForTesting
  final AnalysisRule rule;

  @visibleForTesting
  final RuleSessionContext<JsonParserAnalyzerConfig> sessionContext;

  final CollectionTypeResolver _collectionTypeResolver;

  FromJsonConstructorVisitor(
    AnalysisRule rule,
    RuleSessionContext<JsonParserAnalyzerConfig> sessionContext,
  ) : this._(rule, sessionContext, CollectionTypeResolverFactory.create());

  @visibleForTesting
  FromJsonConstructorVisitor.test(
    AnalysisRule rule,
    RuleSessionContext<JsonParserAnalyzerConfig> sessionContext,
    CollectionTypeResolver collectionTypeResolver,
  ) : this._(rule, sessionContext, collectionTypeResolver);

  FromJsonConstructorVisitor._(
    this.rule,
    this.sessionContext,
    this._collectionTypeResolver,
  );

  void visit(ConstructorDeclaration fromJsonConstructor) {
    final params = fromJsonConstructor.parameters.parameters;
    if (params.length != 1) {
      rule.reportAtNode(
        fromJsonConstructor.parameters,
        arguments: [
          'fromJson constructor must have only one parameter of type Map<String, dynamic> or Map<String, Object?>.',
        ],
      );

      // This check should hide other param specific checks,
      // because we need to have right number of constructors
      // to begin with. So, will return.
      return;
    }

    final paramType = _parameterType(params.first);
    if (paramType == null) {
      rule.reportAtNode(
        params.owner,
        arguments: [
          'fromJson constructor must have only one parameter of type Map<String, dynamic> or Map<String, Object?>.',
        ],
      );
    }

    if (!_isJsonMap(paramType)) {
      rule.reportAtNode(
        paramType,
        arguments: [
          'fromJson constructor must have only one parameter of type Map<String, dynamic> or Map<String, Object?>.',
        ],
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

  TypeAnnotation? _parameterType(FormalParameter param) {
    final actual = param is DefaultFormalParameter ? param.parameter : param;
    return switch (actual) {
      final SimpleFormalParameter p => p.type,
      final FieldFormalParameter p => p.type,
      _ => null,
    };
  }
}
