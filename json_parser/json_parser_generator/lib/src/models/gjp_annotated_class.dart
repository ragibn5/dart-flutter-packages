import 'package:analyzer/dart/element/element.dart';
import 'package:json_parser_generator/src/models/gjp_annotation_config.dart';

class GJPAnnotatedClass {
  final ClassElement element;
  final GJPAnnotationConfig config;

  const GJPAnnotatedClass({required this.element, required this.config});
}
