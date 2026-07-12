// ignore_for_file: unused_element_parameter

enum AppLocale {
  EN(languageCode: 'en'),
  AR(languageCode: 'ar'),
  SYSTEM(languageCode: '');

  final String languageCode;
  final String? scriptCode;
  final String? countryCode;

  const AppLocale({
    required this.languageCode,
    this.scriptCode,
    this.countryCode,
  });
}
