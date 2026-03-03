import 'package:analyzer_core/src/extensions/dart_type_extensions.dart';
import 'package:analyzer_core/src/models/method_signature.dart';
import 'package:analyzer_core/src/services/method_validator/method_validation_error.dart';
import 'package:analyzer_core/src/services/method_validator/method_validator_options.dart';
import 'package:analyzer_core/src/services/parameter_validator/parameter_validation_error.dart';
import 'package:analyzer_core/src/services/parameter_validator/parameter_validator.dart';

class MethodValidator {
  final ParameterValidator _parameterValidator;
  final MethodValidationOptions _options;

  MethodValidator({
    ParameterValidator? parameterValidator,
    MethodValidationOptions options = const MethodValidationOptions(),
  })  : _options = options,
        _parameterValidator = parameterValidator ?? ParameterValidator();

  MethodValidationError? validate({
    required MethodSignature actual,
    required MethodSignature expected,
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
      return MethodNameMismatch(
        message: 'Expected the method name to be `${expected.name}`, '
            'but got `${actual.name}`.',
      );
    }

    // Return type
    final actualType = actual.returnType;
    final expectedType = expected.returnType;
    if (!_options.ignoreReturnType) {
      final actualTypeName = actualType?.displayStringWithTypeArgsSection;
      final expectedTypeName = expectedType?.displayStringWithTypeArgsSection;

      if (actualType == null && expectedType == null) {
      } else if (actualType == null || expectedType == null) {
        return MethodReturnTypeMismatch(
          message: 'Expected the return type to be `$expectedTypeName`, '
              'but got `$actualTypeName`.',
        );
      } else if (!actualType.typesMatch(expectedType)) {
        return MethodReturnTypeMismatch(
          message: 'Expected the return type to be `$expectedTypeName`, '
              'but got `$actualTypeName`.',
        );
      }
    }

    // Parameters
    if (actual.parameters.length != expected.parameters.length) {
      return MethodParameterMismatch(
        parameterValidationError: ParameterCountMismatch(
          message: 'Expected ${expected.parameters.length} parameters, '
              'but got ${actual.parameters.length}.',
        ),
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
        return MethodParameterMismatch(
          parameterValidationError: parameterValidationError,
        );
      }
    }

    return null;
  }

  MethodValidationError? _validateAccessModifier(
    MethodSignature actual,
    MethodSignature expectedSignature,
  ) {
    if (actual.isStatic != expectedSignature.isStatic) {
      return MethodAccessModifierMismatch(
        message: 'Expected `static` access modifier.',
      );
    }
    if (actual.isPublic != expectedSignature.isPublic) {
      return MethodAccessModifierMismatch(
        message: 'Expected the method to be public.',
      );
    }
    if (actual.isPrivate != expectedSignature.isPrivate) {
      return MethodAccessModifierMismatch(
        message: 'Expected the method to be private.',
      );
    }
    if (actual.isExternal != expectedSignature.isExternal) {
      return MethodAccessModifierMismatch(
        message: 'Expected `external` access modifier.',
      );
    }
    if (actual.isAbstract != expectedSignature.isAbstract) {
      return MethodAccessModifierMismatch(
        message: 'Expected the method to be abstract.',
      );
    }
    if (actual.isSynthetic != expectedSignature.isSynthetic) {
      return MethodAccessModifierMismatch(
        message: 'Expected the method to be synthetic.',
      );
    }

    return null;
  }
}
