// ignore_for_file: lines_longer_than_80_chars

import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:json_parser_analyzer/src/models/json_parser_analyzer_config.dart';
import 'package:meta/meta.dart';

class FromJsonStaticMethodVisitor {
  @visibleForTesting
  final AnalysisRule rule;

  @visibleForTesting
  final RuleSessionContext<JsonParserAnalyzerConfig> sessionContext;

  final CollectionTypeResolver _collectionTypeResolver;

  FromJsonStaticMethodVisitor(
    AnalysisRule rule,
    RuleSessionContext<JsonParserAnalyzerConfig> sessionContext,
  ) : this._(rule, sessionContext, CollectionTypeResolverFactory.create());

  @visibleForTesting
  FromJsonStaticMethodVisitor.test(
    AnalysisRule rule,
    RuleSessionContext<JsonParserAnalyzerConfig> sessionContext,
    CollectionTypeResolver collectionTypeResolver,
  ) : this._(rule, sessionContext, collectionTypeResolver);

  FromJsonStaticMethodVisitor._(
    this.rule,
    this.sessionContext,
    this._collectionTypeResolver,
  );

  void visit(
    MethodDeclaration fromJsonMethod,
    ClassDeclaration enclosingClass,
  ) {
    final params = fromJsonMethod.parameters?.parameters;
    if (fromJsonMethod.isGetter || params == null) {
      rule.reportAtToken(
        fromJsonMethod.name,
        arguments: ['static fromJson must not be a getter.'],
      );

      // If it is a getter our param specific checks are not needed.
      // So, will return.
      return;
    }

    if (params.length != 1) {
      rule.reportAtNode(
        fromJsonMethod.parameters,
        arguments: [
          'fromJson method must have only one parameter of type Map<String, dynamic> or Map<String, Object?>.',
        ],
      );
    }

    final paramType = _parameterType(params.first);
    if (paramType == null) {
      rule.reportAtNode(
        params.owner,
        arguments: [
          'fromJson method must have only one parameter of type Map<String, dynamic> or Map<String, Object?>.',
        ],
      );
    }

    if (!_isJsonMap(paramType)) {
      rule.reportAtNode(
        paramType,
        arguments: [
          'fromJson method must have only one parameter of type Map<String, dynamic> or Map<String, Object?>.',
        ],
      );
    }

    final returnType = fromJsonMethod.returnType;
    if (returnType == null) {
      rule.reportAtToken(
        fromJsonMethod.name,
        arguments: ['fromJson method must have an explicit return type.'],
      );

      // If the return type was not declared, checks related
      // to return type's type is irrelevant. So, will return.
      return;
    }

    if (!_isEnclosingClassType(returnType, enclosingClass)) {
      rule.reportAtNode(
        returnType,
        arguments: ['fromJson method must return the enclosing class type.'],
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

  bool _isEnclosingClassType(
    TypeAnnotation typeAnnotation,
    ClassDeclaration enclosingClass,
  ) {
    if (typeAnnotation is! NamedType) {
      return false;
    }

    final type = typeAnnotation.type;
    if (type == null || type is! InterfaceType) {
      return false;
    }

    return type.element.name == enclosingClass.name.lexeme;
  }
}
