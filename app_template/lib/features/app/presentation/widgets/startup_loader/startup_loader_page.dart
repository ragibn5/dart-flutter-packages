import 'package:common_widgets/common_widgets.dart';
import 'package:flutter/material.dart';

class StartupLoaderPage extends StatelessWidget {
  const StartupLoaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: CenteredLoader());
  }
}
