import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_core/analyzer_core.dart';
import 'package:parser_analyzer/src/constants/from_json_constants.dart';
import 'package:parser_analyzer/src/constants/to_json_constants.dart';

class JsonCodableAnalyzer extends Analyzer {
  @override
  String get analyzerName => 'JsonCodableAnalyzer';

  @override
  Future<List<AnalysisIssue>> analyzeFile(
    AnalysisContext context,
    String absoluteFilePath,
  ) async {
    final result =
        await context.currentSession.getResolvedUnit(absoluteFilePath);
    if (result is! ResolvedUnitResult) {
      return [];
    }

    return _analyzeCompilationUnit(result);
  }

  List<AnalysisIssue> _analyzeCompilationUnit(ResolvedUnitResult result) {
    final issueList = <AnalysisIssue>[];

    for (final element in result.unit.declarations) {
      if (element is! ClassDeclaration) continue;

      final annotation = element.findAnnotation('JsonCodable');
      if (annotation == null) continue;

      issueList.addAll(_validateJsonCodableClass(result, element, annotation));
    }

    return issueList;
  }

  List<AnalysisIssue> _validateJsonCodableClass(
    ResolvedUnitResult result,
    ClassDeclaration classDeclaration,
    Annotation annotation,
  ) {
    final issueList = <AnalysisIssue>[];

    final requireToJson =
        annotation.findArgument('requireToJson')?.toBoolValue() ?? true;
    final requireFromJson =
        annotation.findArgument('requireFromJson')?.toBoolValue() ?? true;

    if (requireToJson) {
      final issue = _validateToJsonMethod(result, classDeclaration);
      if (issue != null) {
        issueList.add(issue);
      }
    }

    if (requireFromJson) {
      final issue = _validateFromJsonConstructor(result, classDeclaration);
      if (issue != null) {
        issueList.add(issue);
      }
    }

    return issueList;
  }

  AnalysisIssue? _validateToJsonMethod(
    ResolvedUnitResult result,
    ClassDeclaration classDeclaration,
  ) {
    final toJsonMethod = _findToJsonMethod(classDeclaration);
    if (toJsonMethod == null) {
      return AnalysisIssue.fromToken(
        analysisResult: result,
        token: classDeclaration.name,
        issueData: DEFAULT_MISSING_TO_JSON_METHOD_ISSUE_DATA
            .withPrefixMessage('Missing `toJson` method.'),
      );
    }

    final element = toJsonMethod.declaredFragment?.element;
    if (element == null) {
      throw StateError('The declaration seems to be unresolved.');
    }

    final typeProvider = result.typeProvider;
    final methodValidator = MethodValidator();
    final methodSignature = MethodSignature(
      isStatic: false,
      isPublic: true,
      isPrivate: false,
      isExternal: false,
      isAbstract: false,
      isSynthetic: false,
      name: 'toJson',
      returnType: typeProvider.mapType(
        typeProvider.stringType,
        typeProvider.dynamicType,
      ),
      parameters: const [],
    );

    final validationError = methodValidator.validate(
      actual: MethodSignature.fromMethodElement2(element),
      expected: methodSignature,
    );
    if (validationError != null) {
      return AnalysisIssue.fromNode(
        analysisResult: result,
        node: toJsonMethod,
        issueData: DEFAULT_INVALID_TO_JSON_METHOD_ISSUE_DATA
            .withPrefixMessage(validationError.message),
      );
    }

    return null;
  }

  AnalysisIssue? _validateFromJsonConstructor(
    ResolvedUnitResult result,
    ClassDeclaration classDeclaration,
  ) {
    final fromJsonConstructor = _findFromJsonConstructor(classDeclaration);
    if (fromJsonConstructor == null) {
      return AnalysisIssue.fromNode(
        analysisResult: result,
        node: classDeclaration,
        issueData: DEFAULT_MISSING_FROM_JSON_METHOD_ISSUE_DATA
            .withPrefixMessage('Missing `fromJson` factory constructor.'),
      );
    }

    final element = fromJsonConstructor.declaredFragment?.element;
    if (element == null) {
      throw StateError('The declaration seems to be unresolved.');
    }

    final typeProvider = result.typeProvider;
    final constructorValidator = ConstructorValidator();
    final constructorSignature = ConstructorSignature(
      isConst: false,
      isStatic: false,
      isPublic: true,
      isPrivate: false,
      isFactory: true,
      isExternal: false,
      isSynthetic: false,
      name: 'fromJson',
      parameters: [
        ParameterSignature(
          type: typeProvider.mapType(
            typeProvider.stringType,
            typeProvider.dynamicType,
          ),
          name: 'json',
          isNamed: false,
          isRequired: true,
        ),
      ],
    );

    final validationError = constructorValidator.validate(
      actual: ConstructorSignature.fromConstructorElement2(element),
      expected: constructorSignature,
    );
    if (validationError != null) {
      return AnalysisIssue.fromNode(
        analysisResult: result,
        node: fromJsonConstructor,
        issueData: DEFAULT_INVALID_FROM_JSON_METHOD_ISSUE_DATA
            .withPrefixMessage(validationError.message),
      );
    }

    return null;
  }

  MethodDeclaration? _findToJsonMethod(
    ClassDeclaration classDeclaration,
  ) {
    return classDeclaration.members
        .where(
          (member) =>
              member is MethodDeclaration && member.name.lexeme == 'toJson',
        )
        .firstOrNull as MethodDeclaration?;
  }

  ConstructorDeclaration? _findFromJsonConstructor(
    ClassDeclaration classDeclaration,
  ) {
    return classDeclaration.members
        .where(
          (member) =>
              member is ConstructorDeclaration &&
              member.name?.lexeme == 'fromJson',
        )
        .firstOrNull as ConstructorDeclaration?;
  }
}
