import 'package:equatable/equatable.dart';

class LocaleComponents extends Equatable {
  final String languageCode;
  final String? scriptCode;
  final String? countryCode;

  const LocaleComponents({
    required this.languageCode,
    this.scriptCode,
    this.countryCode,
  });

  @override
  List<Object?> get props => [languageCode, scriptCode, countryCode];
}
