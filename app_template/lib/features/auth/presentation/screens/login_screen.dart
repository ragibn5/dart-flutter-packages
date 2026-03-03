//
// Sample login page, replace with your own,
// inside your preferred feature module/directory.
//

import 'package:app_template/di/provider/dependency_provider.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:app_template/features/auth/presentation/bloc/login_bloc.dart';
import 'package:app_template/generated/assets/assets.gen.dart';
import 'package:app_template/generated/l10n.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class LoginScreen extends StatefulWidget implements AutoRouteWrapper {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(di.get<AuthDataService>()),
      child: this,
    );
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameFieldController = TextEditingController();

  @override
  void dispose() {
    _usernameFieldController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: _handleListenableStates,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: Column(
                spacing: 24,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppAssets.images.profile.image(width: 128),
                  TextField(
                    controller: _usernameFieldController,
                    decoration: InputDecoration(
                      hint: Text(S.of(context).enterUsername),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _handleLoginTapped(context),
                    child: Text(S.of(context).login),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLoginTapped(BuildContext context) {
    context.read<LoginBloc>().add(
      LoginRequested(username: _usernameFieldController.text),
    );
  }

  void _handleListenableStates(BuildContext context, LoginState state) {
    switch (state) {
      case LoginInitial():
        break;
      case LoginComplete():
      // context.router.replace(const HomeRoute());
      default:
        break;
    }
  }
}
