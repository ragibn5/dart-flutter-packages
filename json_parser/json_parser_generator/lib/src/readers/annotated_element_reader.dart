import 'dart:async';

import 'package:generator_core/generator_core.dart';
import 'package:glob/glob.dart';
import 'package:json_parser_generator/src/utils/library_reader_builder.dart';
import 'package:meta/meta.dart';

class AnnotatedElementReader {
  final LibraryReaderBuilder _libraryReaderBuilder;

  const AnnotatedElementReader() : this._(const LibraryReaderBuilder());

  @visibleForTesting
  const AnnotatedElementReader.test(LibraryReaderBuilder libraryReaderBuilder)
    : this._(libraryReaderBuilder);

  const AnnotatedElementReader._(this._libraryReaderBuilder);

  Future<List<AnnotatedElement>> read(
    BuildStep buildStep,
    TypeChecker annotation, {
    String? excludePathPrefix,
  }) async {
    final elements = <AnnotatedElement>[];

    await for (final input in buildStep.findAssets(Glob('lib/**/*.dart'))) {
      if (excludePathPrefix != null &&
          input.path.startsWith(excludePathPrefix)) {
        continue;
      }
      if (!await buildStep.resolver.isLibrary(input)) {
        continue;
      }

      final library = await buildStep.resolver.libraryFor(input);
      final libraryReader = _libraryReaderBuilder(library);
      elements.addAll(libraryReader.annotatedWith(annotation));
    }

    return elements;
  }
}
