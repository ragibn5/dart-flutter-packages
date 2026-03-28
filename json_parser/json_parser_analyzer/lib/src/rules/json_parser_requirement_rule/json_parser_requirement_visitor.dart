// ignore_for_file: lines_longer_than_80_chars

import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:json_parser_analyzer/src/models/json_parser_analyzer_config.dart';
import 'package:json_parser_annotations/json_parser_annotations.dart';
import 'package:meta/meta.dart';

class JsonParserRequirementRuleVisitor extends SimpleAstVisitor<void> {
  @visibleForTesting
  final AnalysisRule rule;

  @visibleForTesting
  final RuleSessionContext<JsonParserAnalyzerConfig> sessionContext;

  final AnnotationTypeResolver _annotationTypeResolver;

  JsonParserRequirementRuleVisitor(
    AnalysisRule rule,
    RuleSessionContext<JsonParserAnalyzerConfig> sessionContext,
  ) : this._(
        rule,
        sessionContext,
        AnnotationTypeResolverFactory.createAnnotationTypeResolver(),
      );

  @visibleForTesting
  JsonParserRequirementRuleVisitor.test(
    AnalysisRule rule,
    RuleSessionContext<JsonParserAnalyzerConfig> sessionContext,
    AnnotationTypeResolver annotationTypeResolver,
  ) : this._(rule, sessionContext, annotationTypeResolver);

  JsonParserRequirementRuleVisitor._(
    this.rule,
    this.sessionContext,
    this._annotationTypeResolver,
  );

  @override
  void visitAnnotation(Annotation node) {
    final annotationName = _annotationTypeResolver.resolveTypeName(node);
    if (annotationName != '$GenerateJsonParser') {
      sessionContext.logger.logInfo(
        tag: '$JsonParserRequirementRuleVisitor',
        message: 'Ignoring unknown annotation: ${node.name.name}',
      );
      return;
    }

    final classNode = node.parent;
    if (classNode is! ClassDeclaration) {
      sessionContext.logger.logWarning(
        tag: '$JsonParserRequirementRuleVisitor',
        message: 'Ignoring non-class node: $classNode',
      );
      return;
    }
    if (classNode.abstractKeyword != null) {
      sessionContext.logger.logWarning(
        tag: '$JsonParserRequirementRuleVisitor',
        message: 'Ignoring abstract-class node: $classNode',
      );
      return;
    }

    _findAndCheckToJsonMethod(classNode);
    _findAndCheckFromJsonConstructorOrStaticMethod(classNode);
  }

  void _findAndCheckToJsonMethod(ClassDeclaration node) {
    final toJsonMethod = node.members
        .whereType<MethodDeclaration>()
        .where((method) => !method.isStatic && method.name.lexeme == 'toJson')
        .firstOrNull;
    if (toJsonMethod == null) {
      rule.reportAtToken(node.name, arguments: ['missing toJson method.']);
    } else {
      _checkToJsonMethod(toJsonMethod);
    }
  }

  void _findAndCheckFromJsonConstructorOrStaticMethod(ClassDeclaration node) {
    final fromJsonConstructor = node.members
        .whereType<ConstructorDeclaration>()
        .where(
          (ctor) =>
              ctor.factoryKeyword != null && ctor.name?.lexeme == 'fromJson',
        )
        .firstOrNull;
    if (fromJsonConstructor != null) {
      _checkFromJsonConstructor(fromJsonConstructor);

      // If we have found a constructor, no need to check for static method.
      // So, returning.
      return;
    }

    final fromJsonMethod = node.members
        .whereType<MethodDeclaration>()
        .where((m) => m.isStatic && m.name.lexeme == 'fromJson')
        .firstOrNull;
    if (fromJsonMethod != null) {
      _checkFromJsonMethod(fromJsonMethod, node);
      return;
    }

    rule.reportAtToken(
      node.name,
      arguments: ['missing fromJson constructor (or a static method).'],
    );
  }

  void _checkToJsonMethod(MethodDeclaration toJsonMethod) {
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
    if (!_isMapStringDynamic(returnType)) {
      rule.reportAtNode(
        returnType,
        arguments: ['toJson method must return Map<String, dynamic>.'],
      );
    }
  }

  void _checkFromJsonConstructor(ConstructorDeclaration fromJsonConstructor) {
    final params = fromJsonConstructor.parameters.parameters;
    if (params.length != 1) {
      rule.reportAtNode(
        fromJsonConstructor.parameters,
        arguments: [
          'fromJson constructor must have only one parameter of type Map<String, dynamic>.',
        ],
      );

      // This check should hide other param specific checks,
      // because we need to have right number of constructors
      // to begin with. So, will return.
      return;
    }

    final paramType = _parameterType(params.first);
    if (!_isMapStringDynamic(paramType)) {
      rule.reportAtNode(
        paramType,
        arguments: [
          'fromJson constructor must have only one parameter of type Map<String, dynamic>.',
        ],
      );
    }
  }

  void _checkFromJsonMethod(
    MethodDeclaration fromJsonMethod,
    ClassDeclaration enclosingClass,
  ) {
    if (fromJsonMethod.isGetter) {
      rule.reportAtToken(
        fromJsonMethod.name,
        arguments: ['static fromJson must not be a getter.'],
      );

      // If it is a getter our param specific checks are not needed.
      // So, will return.
      return;
    }

    final params = fromJsonMethod.parameters?.parameters;
    if (params == null || params.length != 1) {
      rule.reportAtNode(
        fromJsonMethod.parameters,
        arguments: [
          'fromJson method must have only one parameter of type Map<String, dynamic>.',
        ],
      );

      // This check should hide other param specific checks,
      // because we need to have right number of constructors
      // to begin with. So, will return.
      return;
    }

    final paramType = _parameterType(params.first);
    if (!_isMapStringDynamic(paramType)) {
      rule.reportAtNode(
        paramType,
        arguments: [
          'fromJson method must have only one parameter of type Map<String, dynamic>.',
        ],
      );
    }

    final returnType = fromJsonMethod.returnType;
    if (!_isEnclosingClassType(returnType, enclosingClass)) {
      rule.reportAtNode(
        returnType,
        arguments: ['fromJson method must return the enclosing class type.'],
      );
    }
  }

  bool _isMapStringDynamic(TypeAnnotation? typeAnnotation) {
    if (typeAnnotation is! NamedType) {
      return false;
    }

    final type = typeAnnotation.type;
    if (type is! InterfaceType) {
      return false;
    }
    if (type.element.name != 'Map') {
      return false;
    }

    final args = type.typeArguments;
    if (args.length != 2) {
      return false;
    }

    final keyOk = args[0].element?.name == 'String';
    final valueOk = args[1] is DynamicType;

    return keyOk && valueOk;
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
    TypeAnnotation? typeAnnotation,
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
