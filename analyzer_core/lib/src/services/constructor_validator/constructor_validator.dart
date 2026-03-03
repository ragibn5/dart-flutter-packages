import 'package:analyzer_core/src/models/constructor_signature.dart';
import 'package:analyzer_core/src/services/constructor_validator/constructor_validation_error.dart';
import 'package:analyzer_core/src/services/constructor_validator/constructor_validator_options.dart';
import 'package:analyzer_core/src/services/parameter_validator/parameter_validation_error.dart';
import 'package:analyzer_core/src/services/parameter_validator/parameter_validator.dart';

class ConstructorValidator {
  final ParameterValidator _parameterValidator;
  final ConstructorValidationOptions _options;

  ConstructorValidator({
    ParameterValidator? parameterValidator,
    ConstructorValidationOptions options = const ConstructorValidationOptions(),
  })  : _options = options,
        _parameterValidator = parameterValidator ?? ParameterValidator();

  ConstructorValidationError? validate({
    required ConstructorSignature actual,
    required ConstructorSignature expected,
  }) {
    // Modifiers
    if (!_options.ignoreAccessModifiers) {
      final accessModifierValidationResult = _validateAccessModifier(
        actual,
        expected,
      );
      if (accessModifierValidationResult != null) {
        return accessModifierValidationResult;
      }
    }

    // Name
    if (!_options.ignoreName && actual.name != expected.name) {
      return ConstructorNameMismatch(
        message: 'Expected the method name to be `${expected.name}`, '
            'but got `${actual.name}`.',
      );
    }

    // Parameters
    if (actual.parameters.length != expected.parameters.length) {
      return ConstructorParameterMismatch(
        parameterValidationError: ParameterCountMismatch(
            message: 'Expected ${expected.parameters.length} parameters, '
                'but got ${actual.parameters.length}.'),
      );
    }
    for (var i = 0; i < expected.parameters.length; i++) {
      final expectedParam = expected.parameters[i];
      final actualParam = actual.parameters[i];

      final parameterValidationError = _parameterValidator.validate(
        actual: actualParam,
        expected: expectedParam,
      );
      if (parameterValidationError != null) {
        return ConstructorParameterMismatch(
          parameterValidationError: parameterValidationError,
        );
      }
    }

    return null;
  }

  ConstructorValidationError? _validateAccessModifier(
    ConstructorSignature actual,
    ConstructorSignature expectedSignature,
  ) {
    if (actual.isStatic != expectedSignature.isStatic) {
      return ConstructorAccessModifierMismatch(
        message: 'Expected `static` access modifier.',
      );
    }
    if (actual.isPublic != expectedSignature.isPublic) {
      return ConstructorAccessModifierMismatch(
        message: 'Expected the method to be public.',
      );
    }
    if (actual.isPrivate != expectedSignature.isPrivate) {
      return ConstructorAccessModifierMismatch(
        message: 'Expected the method to be private.',
      );
    }
    if (actual.isExternal != expectedSignature.isExternal) {
      return ConstructorAccessModifierMismatch(
        message: 'Expected `external` access modifier.',
      );
    }
    if (actual.isSynthetic != expectedSignature.isSynthetic) {
      return ConstructorAccessModifierMismatch(
        message: 'Expected the method to be synthetic.',
      );
    }

    return null;
  }
}
