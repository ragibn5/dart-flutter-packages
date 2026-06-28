import 'package:app_template/features/settings/domain/entities/app_locale.dart';
import 'package:app_template/features/settings/domain/entities/app_theme_mode.dart';
import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final AppLocale? locale;
  final AppThemeMode? themeMode;

  const AppSettings({this.locale, this.themeMode});

  AppSettings copyWith({AppLocale? locale, AppThemeMode? themeMode}) {
    return AppSettings(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [locale, themeMode];
}
