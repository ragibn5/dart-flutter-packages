import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

class LibraryReaderBuilder {
  const LibraryReaderBuilder();

  LibraryReader call(LibraryElement library) => LibraryReader(library);
}
