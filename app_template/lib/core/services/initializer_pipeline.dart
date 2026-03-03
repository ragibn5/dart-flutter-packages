import 'dart:async';

import 'package:app_template/core/contracts/initializable.dart';

abstract class InitializerPipeline implements Initializable {
  final List<Initializable> _initializables;

  InitializerPipeline(this._initializables);

  @override
  FutureOr<void> initialize() async {
    for (var i = 0; i < _initializables.length; i++) {
      await _initializables[i].initialize();
    }
  }
}
