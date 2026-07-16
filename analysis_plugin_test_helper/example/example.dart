import 'package:analysis_plugin_test_helper/analysis_plugin_test_helper.dart';
import 'package:analyzer/dart/ast/ast.dart';

Future<void> main() async {
  await resolveSourceExample();
  await findAnnotationExample();
  await findMethodDeclarationExample();
  await findConstructorDeclarationExample();
  await findImportDirectiveExample();
}

/// Resolves Dart source strings into fully analyzed ASTs.
///
/// The [DartUnitResolver] allows you to resolve standalone Dart code strings
/// into [ResolvedUnitResult] instances, enabling access to resolved elements,
/// constant values, and type information.
Future<void> resolveSourceExample() async {
  final resolver = DartUnitResolver();

  // Set up a temporary directory for resolution
  await resolver.setUp();

  try {
    // Resolve a Dart source string
    final result = await resolver.resolveSource('''
      class MyAnnotation {
        const MyAnnotation();
      }

      @MyAnnotation()
      class Foo {
        void myMethod() {}
      }
    ''');

    // Access the resolved compilation unit
    final unit = result.unit;
    print('Found ${unit.declarations.length} declarations');
  } finally {
    // Clean up the temporary directory
    await resolver.tearDown();
  }
}

/// Finds annotations on declarations.
///
/// The [findAnnotation] function searches for annotations by their resolved
/// type name on any declaration of a given type.
Future<void> findAnnotationExample() async {
  final resolver = DartUnitResolver();
  await resolver.setUp();

  try {
    final result = await resolver.resolveSource('''
      class MyAnnotation {
        const MyAnnotation();
      }

      @MyAnnotation()
      class Foo {}

      @MyAnnotation()
      void myFunction() {}
    ''');

    // Find annotation on a class declaration
    final classAnnotation = findAnnotation<ClassDeclaration>(
      result.unit,
      annotationName: 'MyAnnotation',
    );
    print('Found annotation on class: ${classAnnotation != null}');

    // Find annotation on a function declaration
    final functionAnnotation = findAnnotation<FunctionDeclaration>(
      result.unit,
      annotationName: 'MyAnnotation',
    );
    print('Found annotation on function: ${functionAnnotation != null}');
  } finally {
    await resolver.tearDown();
  }
}

/// Finds method declarations by name.
///
/// The [findMethodDeclaration] function searches for methods by name
/// across classes, mixins, extensions, extension types, and enums.
Future<void> findMethodDeclarationExample() async {
  final resolver = DartUnitResolver();
  await resolver.setUp();

  try {
    final result = await resolver.resolveSource('''
      class MyClass {
        void myMethod() {}
        
        static void myStaticMethod() {}
        
        int get myGetter => 42;
      }
    ''');

    // Find a specific method
    final method = findMethodDeclaration(result.unit, 'myMethod');
    print('Found method: ${method?.name.lexeme}');

    // Find a static method
    final staticMethod = findMethodDeclaration(result.unit, 'myStaticMethod');
    print('Found static method: ${staticMethod?.name.lexeme}');
  } finally {
    await resolver.tearDown();
  }
}

/// Finds constructor declarations by name.
///
/// The [findConstructorDeclaration] function searches for constructors
/// by name. Pass `null` to find the default constructor.
Future<void> findConstructorDeclarationExample() async {
  final resolver = DartUnitResolver();
  await resolver.setUp();

  try {
    final result = await resolver.resolveSource('''
      class MyClass {
        MyClass();
        
        MyClass.named();
        
        MyClass.withParams(int param);
        
        factory MyClass.factory() = MyClass.named;
      }
    ''');

    // Find the default constructor
    final defaultConstructor = findConstructorDeclaration(result.unit, null);
    print('Found default constructor: ${defaultConstructor != null}');

    // Find a named constructor
    final namedConstructor = findConstructorDeclaration(result.unit, 'named');
    print('Found named constructor: ${namedConstructor?.name?.lexeme}');

    // Find a factory constructor
    final factoryConstructor = findFactoryConstructorDeclaration(
      result.unit,
      'factory',
    );
    print('Found factory constructor: ${factoryConstructor != null}');
  } finally {
    await resolver.tearDown();
  }
}

/// Finds import directives in source code.
///
/// The [findImportDirective] function returns the first import directive
/// found in a compilation unit.
Future<void> findImportDirectiveExample() async {
  final resolver = DartUnitResolver();
  await resolver.setUp();

  try {
    final result = await resolver.resolveSource('''
      import 'dart:core';
      
      class MyClass {}
    ''');

    // Find the first import directive
    final importDirective = findImportDirective(result.unit);
    print('Found import: ${importDirective?.uri.stringValue}');
  } finally {
    await resolver.tearDown();
  }
}
