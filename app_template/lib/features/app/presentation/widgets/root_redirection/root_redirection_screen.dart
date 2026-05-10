import 'package:app_template/shared/loader_page/common_loader_page.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

/// A redirection page used with route-guards to conditionally redirect us
/// to other pages.
///
/// The page may or may not be navigated to, based on the navigation logic.
/// If it is NOT intended to be shown, make sure your redirection logic is
/// exhaustive and bypasses navigation to this page.
@RoutePage()
class RootRedirectionScreen extends StatelessWidget {
  const RootRedirectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: CommonLoaderScreen());
  }
}
