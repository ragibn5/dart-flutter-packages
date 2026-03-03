import 'package:analyzer_core/src/extensions/dart_type_extensions.dart';
import 'package:analyzer_core/src/models/parameter_signature.dart';
import 'package:analyzer_core/src/services/parameter_validator/parameter_validation_error.dart';
import 'package:analyzer_core/src/services/parameter_validator/parameter_validation_options.dart';

class ParameterValidator {
  final ParameterValidationOptions _options;

  ParameterValidator(
      {ParameterValidationOptions options = const ParameterValidationOptions()})
      : _options = options;

  ParameterValidationError? validate({
    required ParameterSignature actual,
    required ParameterSignature expected,
  }) {
    // Type validation
    final actualType = actual.type;
    final expectedType = expected.type;
    if (!_options.ignoreType) {
      final actualTypeName = actualType?.displayStringWithTypeArgsSection;
      final expectedTypeName = expectedType?.displayStringWithTypeArgsSection;

      if (actualType == null && expectedType == null) {
      } else if (actualType == null || expectedType == null) {
        return ParameterTypeMismatch(
          message: 'Expected parameter type to be `$expectedTypeName`, '
              'but got `$actualTypeName`.',
        );
      } else if (!actualType.typesMatch(expectedType)) {
        return ParameterTypeMismatch(
          message: 'Expected parameter type to be `$expectedTypeName`, '
              'but got `$actualTypeName`.',
        );
      }
    }

    // Name validation
    if (!_options.ignoreName && actual.name != expected.name) {
      return ParameterNameMismatch(
        message: 'Expected parameter name to be `${expected.name}`, '
            'but got `${actual.name}`.',
      );
    }

    // Required status validation
    if (!_options.ignoreRequiredStatus &&
        actual.isRequired != expected.isRequired) {
      return ParameterRequiredMismatch(
        message: expected.isRequired
            ? 'Expected parameter to be required.'
            : 'Expected parameter to be optional.',
      );
    }

    // Named status validation
    if (!_options.ignoreNamedStatus && actual.isNamed != expected.isNamed) {
      return ParameterNamedMismatch(
        message: expected.isNamed
            ? 'Expected parameter to be named.'
            : 'Expected parameter to be positional.',
      );
    }

    return null;
  }
}
