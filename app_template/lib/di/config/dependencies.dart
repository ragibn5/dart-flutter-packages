import 'dart:async';

import 'package:app_template/di/config/dependencies.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

@InjectableInit(throwOnMissingDependencies: true)
Future<GetIt> configureDependencies(GetIt registrar, Environment? env) async =>
    registrar.init(environment: env?.name);
