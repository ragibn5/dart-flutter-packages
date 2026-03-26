// ignore_for_file: lines_longer_than_80_chars

import 'package:analysis_server_core/analysis_server_core.dart';
import 'package:json_parser_analyzer/models/json_parser_lint_config.dart';
import 'package:json_parser_annotations/json_parser_annotations.dart';
import 'package:meta/meta.dart';

class JsonParserRequirementRuleVisitor extends SimpleAstVisitor<void> {
  @visibleForTesting
  final AnalysisRule rule;

  @visibleForTesting
  final RuleSessionContext<JsonParserLintConfig> sessionContext;

  JsonParserRequirementRuleVisitor(
    AnalysisRule rule,
    RuleSessionContext<JsonParserLintConfig> sessionContext,
  ) : this._(rule, sessionContext);

  @visibleForTesting
  JsonParserRequirementRuleVisitor.test(
    AnalysisRule rule,
    RuleSessionContext<JsonParserLintConfig> sessionContext,
  ) : this._(rule, sessionContext);

  JsonParserRequirementRuleVisitor._(this.rule, this.sessionContext);

  @override
  void visitAnnotation(Annotation node) {
    if (node.name.name != '$GenerateJsonParser') {
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
      _checkFromJsonMethod(fromJsonMethod);
      return;
    }

    rule.reportAtToken(
      node.name,
      arguments: ['missing fromJson constructor (or a static method).'],
    );
  }

  void _checkToJsonMethod(MethodDeclaration toJsonMethod) {
    final params = toJsonMethod.parameters?.parameters;
    if (params != null && params.isNotEmpty) {
      rule.reportAtNode(
        toJsonMethod.parameters,
        arguments: ['toJson method should not have parameters.'],
      );
    }

    final returnType = toJsonMethod.returnType;
    if (!_isMapStringDynamic(returnType)) {
      rule.reportAtNode(
        returnType,
        arguments: ['toJson method should return Map<String, dynamic>.'],
      );
    }
  }

  void _checkFromJsonConstructor(ConstructorDeclaration fromJsonConstructor) {
    final params = fromJsonConstructor.parameters.parameters;
    if (params.length != 1) {
      rule.reportAtNode(
        fromJsonConstructor.parameters,
        arguments: [
          'fromJson constructor should have only one parameter of type Map<String, dynamic>.',
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
          'fromJson constructor should have only one parameter of type Map<String, dynamic>.',
        ],
      );
    }
  }

  void _checkFromJsonMethod(MethodDeclaration fromJsonMethod) {
    if (fromJsonMethod.isGetter) {
      rule.reportAtToken(
        fromJsonMethod.name,
        arguments: ['static fromJson should not be a getter.'],
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
          'fromJson method should have only one parameter of type Map<String, dynamic>.',
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
          'fromJson method should have only one parameter of type Map<String, dynamic>.',
        ],
      );
    }
  }

  bool _isMapStringDynamic(TypeAnnotation? typeAnnotation) {
    if (typeAnnotation is! NamedType) return false;
    if (typeAnnotation.name.lexeme != 'Map') return false;

    final args = typeAnnotation.typeArguments?.arguments;
    if (args == null || args.length != 2) return false;

    final keyOk =
        args[0] is NamedType && (args[0] as NamedType).name.lexeme == 'String';
    final valueOk =
        args[1] is NamedType && (args[1] as NamedType).name.lexeme == 'dynamic';

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
}
