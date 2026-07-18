// ignore_for_file: lines_longer_than_80_chars

import 'package:analysis_server_plugin_core/analysis_server_plugin_core.dart';
import 'package:json_parser_analyzer/src/models/json_parser_analyzer_config.dart';
import 'package:json_parser_analyzer/src/rules/json_parser_requirement_rule/from_json_constructor_visitor.dart';
import 'package:json_parser_analyzer/src/rules/json_parser_requirement_rule/from_json_static_method_visitor.dart';
import 'package:json_parser_analyzer/src/rules/json_parser_requirement_rule/to_json_method_visitor.dart';
import 'package:json_parser_annotations/json_parser_annotations.dart';
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
    this.missingToJsonContextMessage = 'missing toJson method.',
    this.missingFromJsonContextMessage =
        'missing fromJson constructor (or a static method).',
  });
}

class JsonParserRequirementRuleVisitor extends SimpleAstVisitor<void> {
  @visibleForTesting
  final AnalysisRule rule;

  @visibleForTesting
  final JsonParserRequirementRuleVisitorConfig visitorConfig;

  @visibleForTesting
  final RuleSessionContext<JsonParserAnalyzerConfig> sessionContext;

  final AnnotationTypeResolver _annotationTypeResolver;
  final ToJsonMethodVisitor _toJsonMethodVisitor;
  final FromJsonConstructorVisitor _fromJsonConstructorVisitor;
  final FromJsonStaticMethodVisitor _fromJsonStaticMethodVisitor;

  JsonParserRequirementRuleVisitor(
    AnalysisRule rule,
    RuleSessionContext<JsonParserAnalyzerConfig> sessionContext,
  ) : this._(
        rule,
        JsonParserRequirementRuleVisitorConfig(),
        sessionContext,
        AnnotationTypeResolverFactory.create(),
        ToJsonMethodVisitor(rule, sessionContext),
        FromJsonConstructorVisitor(rule, sessionContext),
        FromJsonStaticMethodVisitor(rule, sessionContext),
      );

  @visibleForTesting
  JsonParserRequirementRuleVisitor.test(
    AnalysisRule rule,
    JsonParserRequirementRuleVisitorConfig visitorConfig,
    RuleSessionContext<JsonParserAnalyzerConfig> sessionContext,
    AnnotationTypeResolver annotationTypeResolver,
    ToJsonMethodVisitor toJsonMethodVisitor,
    FromJsonConstructorVisitor fromJsonConstructorVisitor,
    FromJsonStaticMethodVisitor fromJsonStaticMethodVisitor,
  ) : this._(
        rule,
        visitorConfig,
        sessionContext,
        annotationTypeResolver,
        toJsonMethodVisitor,
        fromJsonConstructorVisitor,
        fromJsonStaticMethodVisitor,
      );

  JsonParserRequirementRuleVisitor._(
    this.rule,
    this.visitorConfig,
    this.sessionContext,
    this._annotationTypeResolver,
    this._toJsonMethodVisitor,
    this._fromJsonConstructorVisitor,
    this._fromJsonStaticMethodVisitor,
  );

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
