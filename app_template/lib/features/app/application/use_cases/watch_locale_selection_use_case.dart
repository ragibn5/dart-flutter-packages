import 'package:app_template/features/settings/domain/entities/app_locale.dart';

abstract interface class WatchLocaleSelectionUseCase {
  /// A stream of user selected locale.
  Stream<AppLocale> call();
}
