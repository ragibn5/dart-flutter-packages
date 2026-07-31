import 'package:analyzer/dart/element/element.dart';
import 'package:generator_core/generator_core.dart';

class LibraryReaderBuilder {
  const LibraryReaderBuilder();

  LibraryReader call(LibraryElement library) => LibraryReader(library);
}
