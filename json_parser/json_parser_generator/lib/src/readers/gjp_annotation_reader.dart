import 'package:analyzer/dart/element/element.dart';
import 'package:generator_core/generator_core.dart';
import 'package:json_parser_generator/src/models/gjp_annotated_class.dart';
import 'package:json_parser_generator/src/models/gjp_annotation_config.dart';

class GJPAnnotationReader {
  const GJPAnnotationReader();

  List<GJPAnnotatedClass> read(List<AnnotatedElement> elements) {
    final classes = <GJPAnnotatedClass>[];

    for (final annotated in elements) {
      if (annotated.element is! ClassElement) {
        continue;
      }

      final keysReader = annotated.annotation.read('registryKeys');
      final keys = keysReader.isNull
          ? <String>{}
          : keysReader.setValue
                .map((e) => e.toStringValue()?.toLowerCase().trim())
                .where((key) => key?.isNotEmpty ?? false)
                .whereType<String>()
                .toSet();

      classes.add(
        GJPAnnotatedClass(
          element: annotated.element as ClassElement,
          config: GJPAnnotationConfig(registryKeys: keys),
        ),
      );
    }

    return classes;
  }
}
