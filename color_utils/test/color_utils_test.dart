import 'brightness_extension_test.dart' as brightness_extension_test;
import 'randomization_utils_test.dart' as randomization_utils_test;
import 'representation_extensions_test.dart' as representation_extensions_test;
import 'representation_utils_test.dart' as representation_utils_test;
import 'transformation_extension_test.dart' as transformation_extension_test;

void main() {
  // extensions test
  brightness_extension_test.main();
  representation_extensions_test.main();
  transformation_extension_test.main();

  // utils test
  randomization_utils_test.main();
  representation_utils_test.main();
}
