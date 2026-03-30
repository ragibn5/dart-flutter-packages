// ignore_for_file: lines_longer_than_80_chars

import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:json_parser_analyzer/src/models/json_parser_analyzer_config.dart';
import 'package:meta/meta.dart';

class FromJsonStaticMethodVisitorConfig {
  final String getterNotAllowedContextMessage;
  final String missingParamDeclarationContextMessage;
  final String wrongParamCountContextMessage;
  final String wrongParamDeclarationTypeContextMessage;
  final String invalidParamTypeContextMessage;

  FromJsonStaticMethodVisitorConfig({
    this.getterNotAllowedContextMessage =
        'static fromJson must not be a getter.',
    this.missingParamDeclarationContextMessage =
        'fromJson method must have only one positional parameter of type Map<String, dynamic> or Map<String, Object?>.',
    this.wrongParamCountContextMessage =
        'fromJson method must have only one positional parameter of type Map<String, dynamic> or Map<String, Object?>.',
    this.wrongParamDeclarationTypeContextMessage =
        'fromJson method must have only one positional parameter of type Map<String, dynamic> or Map<String, Object?>.',
    this.invalidParamTypeContextMessage =
        'fromJson method must have only one positional parameter of type Map<String, dynamic> or Map<String, Object?>.',
  });
}

class FromJsonStaticMethodVisitor {
  @visibleForTesting
  final AnalysisRule rule;

  @visibleForTesting
  final FromJsonStaticMethodVisitorConfig visitorConfig;

  @visibleForTesting
  final RuleSessionContext<JsonParserAnalyzerConfig> sessionContext;

  final CollectionTypeResolver _collectionTypeResolver;

  FromJsonStaticMethodVisitor(
    AnalysisRule rule,
    RuleSessionContext<JsonParserAnalyzerConfig> sessionContext,
  ) : this._(
        rule,
        FromJsonStaticMethodVisitorConfig(),
        sessionContext,
        CollectionTypeResolverFactory.create(),
      );

  @visibleForTesting
  FromJsonStaticMethodVisitor.test(
    AnalysisRule rule,
    FromJsonStaticMethodVisitorConfig visitorConfig,
    RuleSessionContext<JsonParserAnalyzerConfig> sessionContext,
    CollectionTypeResolver collectionTypeResolver,
  ) : this._(rule, visitorConfig, sessionContext, collectionTypeResolver);

  FromJsonStaticMethodVisitor._(
    this.rule,
    this.visitorConfig,
    this.sessionContext,
    this._collectionTypeResolver,
  );

  void visit(
    MethodDeclaration fromJsonMethod,
    ClassDeclaration enclosingClass,
  ) {
    if (fromJsonMethod.isGetter) {
      rule.reportAtToken(
        fromJsonMethod.name,
        arguments: [visitorConfig.getterNotAllowedContextMessage],
      );

      // If it is a getter, it won't have any params,
      // hence our param specific checks are not needed.
      // So, will return.
      return;
    }

    _checkParamType(fromJsonMethod);

    final returnType = fromJsonMethod.returnType;
    if (returnType == null) {
      rule.reportAtToken(
        fromJsonMethod.name,
        arguments: ['fromJson method must have an explicit return type.'],
      );

      // If the return type was not declared, further checks
      // related to return type's type is irrelevant. So, will return.
      return;
    }

    if (!_isEnclosingClassType(returnType, enclosingClass)) {
      rule.reportAtNode(
        returnType,
        arguments: ['fromJson method must return the enclosing class type.'],
      );
    }
  }

  void _checkParamType(MethodDeclaration fromJsonMethod) {
    final params = fromJsonMethod.parameters?.parameters;
    if (params == null) {
      rule.reportAtToken(
        fromJsonMethod.name,
        arguments: [visitorConfig.missingParamDeclarationContextMessage],
      );

      // This can only happen if the method is a getter, on which case
      // the FormalParameterList will be null. Although we checked for
      // getter previously, this one is merely for certainty. Also, if
      // there are not params, there is no further param specific checks
      // needed. So, will return.
      return;
    }

    if (params.length != 1) {
      rule.reportAtNode(
        fromJsonMethod.parameters,
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
