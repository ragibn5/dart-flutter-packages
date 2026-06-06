import 'package:flutter/material.dart';
import 'package:snacker/src/enums/snack_type.dart';
import 'package:snacker/src/snacker.dart';

class ScaffoldMessengerSnacker extends Snacker {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  const ScaffoldMessengerSnacker(this._scaffoldMessengerKey);

  @override
  ScaffoldMessengerState? getCurrentState() {
    return _scaffoldMessengerKey.currentState;
  }

  @override
  Color getSnackBarBackgroundColor(SnackType type) {
    switch (type) {
      case .INFO:
        return const Color(0xFF2196F3);
      case .SUCCESS:
        return const Color(0xFF4CAF50);
      case .WARNING:
        return const Color(0xFFFF9800);
      case .ERROR:
        return const Color(0xFFF44336);
    }
  }
}
