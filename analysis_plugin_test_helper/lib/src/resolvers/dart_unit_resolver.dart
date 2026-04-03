import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:path/path.dart' as path;

/// A test utility that resolves Dart source strings into fully analyzed
/// [ResolvedUnitResult] instances, enabling access to resolved elements,
/// constant values, and type information.
///
/// This class is intended for use in tests that require a fully resolved AST —
/// for example, testing services that call
/// [ElementAnnotation.computeConstantValue] or inspect [DartType] information.
///
/// The source passed to [resolveSource] must be a **standalone, independently
/// executable Dart file** — meaning it must be valid Dart on its own, with no
/// unresolved imports or missing declarations. All referenced classes,
/// annotations, and types must be defined within the same source string.
///
/// Usage:
/// ```dart
/// final resolver = DartUnitResolver();
///
/// setUpAll(() async => resolver.setUp());
/// tearDownAll(() async => resolver.tearDown());
///
/// test('example', () async {
///   final result = await resolver.resolveSource('''
///     class MyAnnotation {
///       const MyAnnotation();
///     }
///
///     @MyAnnotation()
///     class Foo {}
///   ''');
///
///   final annotation = result.findAnnotation(annotationName: 'MyAnnotation');
/// });
/// ```
class DartUnitResolver {
  late Directory _tempDir;

  /// Sets up a temporary directory used to write and resolve Dart source files.
  ///
  /// Must be called before [resolveSource], typically in a test [setUp] block.
  Future<void> setUp() async {
    _tempDir = Directory.systemTemp.createTempSync('resolved_ast_test_');
  }

  /// Deletes the temporary directory created in [setUp].
  ///
  /// Must be called after all tests, typically in a [tearDownAll] block.
  Future<void> tearDown() async {
    _tempDir.deleteSync(recursive: true);
  }

  /// Resolves the given Dart [source] string into a [ResolvedUnitResult].
  ///
  /// The [source] must represent a **standalone, independently executable Dart
  /// file**. All types, annotations, and declarations referenced in the source
  /// must be defined within the same string — external package imports will not
  /// resolve and will cause resolution errors.
  ///
  /// Throws a [StateError] if fails to produce a [ResolvedUnitResult].
  Future<ResolvedUnitResult> resolveSource(String source) async {
    AnalysisContextCollection? contextCollection;
    try {
      contextCollection = AnalysisContextCollection(
        includedPaths: [_tempDir.path],
      );

      final file = File(path.join(_tempDir.path, 'test_input.dart'));

      file.writeAsStringSync(source);

      final context = contextCollection.contextFor(file.path);
      final result = await context.currentSession.getResolvedUnit(file.path);
      if (result is! ResolvedUnitResult) {
        throw StateError('Failed to resolve source:\n$source');
      }

      return result;
    } finally {
      contextCollection?.dispose();
    }
  }
}
