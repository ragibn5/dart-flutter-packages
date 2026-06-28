import 'dart:async';

import 'package:app_template/features/auth/domain/entities/auth_data.dart';
import 'package:app_template/features/auth/domain/services/auth_data_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthDataService _authDataService;

  LoginBloc(this._authDataService) : super(LoginInitial()) {
    on<LoginRequested>(_handleLoginEvent);
  }

  Future<void> _handleLoginEvent(
    LoginRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginInProgress());

    try {
      await _authDataService.setCurrentAuthData(
        AuthData(
          userId: event.username,
          accessToken: 'accessToken',
          refreshToken: 'refreshToken',
          accessTokenExpiry: DateTime.now().add(const Duration(days: 1)),
          refreshTokenExpiry: DateTime.now().add(const Duration(days: 3)),
        ),
      );

      emit(LoginComplete());
    } catch (e) {
      emit(LoginError());
      return;
    }
  }
}
