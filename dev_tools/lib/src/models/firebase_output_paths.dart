import 'package:meta/meta.dart';

@immutable
class FirebaseOutputPaths {
  final String ios;
  final String android;
  final String dart;

  const FirebaseOutputPaths({
    required this.ios,
    required this.android,
    required this.dart,
  });

  static const FirebaseOutputPaths defaults = FirebaseOutputPaths(
    ios: 'ios/Config/Firebase/{flavor}/GoogleService-Info.plist',
    android: 'android/app/src/{flavor}/google-services.json',
    dart:
        'lib/features/app/infrastructure/config/firebase/firebase_options_{flavor}.dart',
  );

  /// Substitutes the `{flavor}` placeholder in every path with [flavor].
  FirebaseOutputPaths forFlavor(String flavor) => FirebaseOutputPaths(
        ios: ios.replaceAll('{flavor}', flavor),
        android: android.replaceAll('{flavor}', flavor),
        dart: dart.replaceAll('{flavor}', flavor),
      );

  @override
  bool operator ==(Object other) =>
      other is FirebaseOutputPaths &&
      ios == other.ios &&
      android == other.android &&
      dart == other.dart;

  @override
  int get hashCode => Object.hash(ios, android, dart);
}
