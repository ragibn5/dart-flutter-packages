import 'package:app_template/shared/loader_page/common_loader_page.dart';
import 'package:flutter/material.dart';

class StartupLoaderPage extends StatelessWidget {
  const StartupLoaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: CommonLoaderScreen());
  }
}
