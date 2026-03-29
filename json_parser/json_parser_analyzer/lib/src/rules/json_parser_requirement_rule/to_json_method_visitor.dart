// ignore_for_file: lines_longer_than_80_chars

import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:json_parser_analyzer/src/models/json_parser_analyzer_config.dart';
import 'package:meta/meta.dart';

class ToJsonMethodVisitor {
  @visibleForTesting
  final AnalysisRule rule;

  @visibleForTesting
  final RuleSessionContext<JsonParserAnalyzerConfig> sessionContext;

  final CollectionTypeResolver _collectionTypeResolver;

  ToJsonMethodVisitor(
    AnalysisRule rule,
    RuleSessionContext<JsonParserAnalyzerConfig> sessionContext,
  ) : this._(rule, sessionContext, CollectionTypeResolverFactory.create());

  @visibleForTesting
  ToJsonMethodVisitor.test(
    AnalysisRule rule,
    RuleSessionContext<JsonParserAnalyzerConfig> sessionContext,
    CollectionTypeResolver collectionTypeResolver,
  ) : this._(rule, sessionContext, collectionTypeResolver);

  ToJsonMethodVisitor._(
    this.rule,
    this.sessionContext,
    this._collectionTypeResolver,
  );

  void visit(MethodDeclaration toJsonMethod) {
    if (toJsonMethod.isGetter) {
      rule.reportAtToken(
        toJsonMethod.name,
        arguments: ['toJson method must not be a getter.'],
      );

      // If it is a getter our param specific checks are not needed.
      // So, will return.
      return;
    }

    final params = toJsonMethod.parameters?.parameters ?? [];
    if (params.isNotEmpty) {
      rule.reportAtNode(
        toJsonMethod.parameters,
        arguments: ['toJson method must not have parameters.'],
      );
    }

    final returnType = toJsonMethod.returnType;
    if (returnType == null) {
      rule.reportAtToken(
        toJsonMethod.name,
        arguments: ['toJson method must have an explicit return type.'],
      );

      // If the return type was not declared, checks related
      // to return type's type is irrelevant. So, will return.
      return;
    }

    if (!_isJsonMap(returnType)) {
      rule.reportAtNode(
        returnType,
        arguments: [
          'toJson method must return Map<String, dynamic> or Map<String, Object?>.',
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
}
