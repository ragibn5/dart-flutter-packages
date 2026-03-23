import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:source_gen/source_gen.dart';

class AnnotatedElementReader {
  const AnnotatedElementReader();

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
      final libraryReader = LibraryReader(library);
      elements.addAll(libraryReader.annotatedWith(annotation));
    }

    return elements;
  }
}
