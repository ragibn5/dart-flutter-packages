import 'package:json_parser_annotations/json_parser_annotations.dart';

@GenerateJsonParser()
class TestModel {
  final String name;
  final int value;

  TestModel({required this.name, required this.value});
}
