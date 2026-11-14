// ignore_for_file: lines_longer_than_80_chars

import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:json_parser_annotations/json_parser_annotations.dart'
    show GenerateJsonParser;
import 'package:json_parser_linter/src/models/json_parser_linter_config.dart';
import 'package:json_parser_linter/src/rules/json_parser_requirement_rule/from_json_constructor_visitor.dart';
import 'package:json_parser_linter/src/rules/json_parser_requirement_rule/from_json_static_method_visitor.dart';
import 'package:json_parser_linter/src/rules/json_parser_requirement_rule/to_json_method_visitor.dart';
import 'package:meta/meta.dart';

class JsonParserRequirementRuleVisitorConfig {
  final String toJsonMethodName;
  final String fromJsonConstructorName;
  final String fromJsonStaticMethodName;

  final String missingToJsonContextMessage;
  final String missingFromJsonContextMessage;

  JsonParserRequirementRuleVisitorConfig({
    this.toJsonMethodName = 'toJson',
    this.fromJsonConstructorName = 'fromJson',
    this.fromJsonStaticMethodName = 'fromJson',
    this.missingToJsonContextMessage = 'missing toJson method',
    this.missingFromJsonContextMessage =
        'missing fromJson constructor or static method',
  });
}

class JsonParserRequirementRuleVisitor extends SimpleAstVisitor<void> {
  @visibleForTesting
  final AnalysisRule rule;

  @visibleForTesting
  final JsonParserRequirementRuleVisitorConfig visitorConfig;

  @visibleForTesting
  final RuleSessionContext<JsonParserLinterConfig> sessionContext;

  final AnnotationTypeResolver _annotationTypeResolver;
  final ToJsonMethodVisitor _toJsonMethodVisitor;
  final FromJsonConstructorVisitor _fromJsonConstructorVisitor;
  final FromJsonStaticMethodVisitor _fromJsonStaticMethodVisitor;

  JsonParserRequirementRuleVisitor(
    this.rule,
    this.sessionContext, {
    @visibleForTesting JsonParserRequirementRuleVisitorConfig? visitorConfig,
    @visibleForTesting AnnotationTypeResolver? annotationTypeResolver,
    @visibleForTesting ToJsonMethodVisitor? toJsonMethodVisitor,
    @visibleForTesting FromJsonConstructorVisitor? fromJsonConstructorVisitor,
    @visibleForTesting FromJsonStaticMethodVisitor? fromJsonStaticMethodVisitor,
  }) : visitorConfig =
           visitorConfig ?? JsonParserRequirementRuleVisitorConfig(),
       _annotationTypeResolver =
           annotationTypeResolver ?? AnnotationTypeResolverFactory.create(),
       _toJsonMethodVisitor =
           toJsonMethodVisitor ?? ToJsonMethodVisitor(rule, sessionContext),
       _fromJsonConstructorVisitor =
           fromJsonConstructorVisitor ??
           FromJsonConstructorVisitor(rule, sessionContext),
       _fromJsonStaticMethodVisitor =
           fromJsonStaticMethodVisitor ??
           FromJsonStaticMethodVisitor(rule, sessionContext);

  @override
  void visitAnnotation(Annotation node) {
    if (!_isGenerateJsonParserAnnotation(node)) {
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
        .where(
          (method) =>
              !method.isStatic &&
              method.name.lexeme == visitorConfig.toJsonMethodName,
        )
        .firstOrNull;
    if (toJsonMethod == null) {
      rule.reportAtToken(
        node.name,
        arguments: [visitorConfig.missingToJsonContextMessage],
      );

      // If there is no toJson method, we have nothing to process further.
      // So, returning.
      return;
    }

    _toJsonMethodVisitor.visit(toJsonMethod);
  }

  void _findAndCheckFromJsonConstructorOrStaticMethod(ClassDeclaration node) {
    final fromJsonConstructor = node.members
        .whereType<ConstructorDeclaration>()
        .where(
          (ctor) =>
              ctor.factoryKeyword != null &&
              ctor.name?.lexeme == visitorConfig.fromJsonConstructorName,
        )
        .firstOrNull;
    if (fromJsonConstructor != null) {
      _fromJsonConstructorVisitor.visit(fromJsonConstructor);

      // If we have found a constructor, no need to check for static method.
      // So, returning.
      return;
    }

    final fromJsonMethod = node.members
        .whereType<MethodDeclaration>()
        .where(
          (m) =>
              m.isStatic &&
              m.name.lexeme == visitorConfig.fromJsonStaticMethodName,
        )
        .firstOrNull;
    if (fromJsonMethod != null) {
      _fromJsonStaticMethodVisitor.visit(fromJsonMethod, node);

      // We have found the static fromJson method, nothing to do now.
      // So, returning.
      return;
    }

    // Found none - report.
    rule.reportAtToken(
      node.name,
      arguments: [visitorConfig.missingFromJsonContextMessage],
    );
  }

  bool _isGenerateJsonParserAnnotation(Annotation node) {
    return _annotationTypeResolver.resolveTypeName(node) ==
        '$GenerateJsonParser';
  }
}
