import 'package:auto_route/auto_route.dart';
import 'package:bloc/bloc.dart';
import 'package:dala_ishchisi/common/constants/app_globals.dart';
import 'package:dala_ishchisi/domain/facades/auth_facade.dart';
import 'package:dala_ishchisi/domain/models/meta_model.dart';
import 'package:dala_ishchisi/domain/models/user_info_model.dart';
import 'package:dala_ishchisi/infrastructure/services/cache/app_cache.dart';
import 'package:dala_ishchisi/infrastructure/services/cache/auth_cache.dart';
import 'package:dala_ishchisi/main.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../var_status.dart';

part 'auth_bloc.freezed.dart';
part 'auth_event.dart';
part 'auth_state.dart';

@Injectable()
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthFacade _facade;
  final AuthCache _authCache;
  final AppCache _appCache;

  AuthBloc(this._facade, this._authCache, this._appCache)
      : super(const AuthState.initial()) {
    on<_Init>(_onInit);
    on<_Login>(_onLogin);
    on<_UserInfo>(_onUserInfo);
    on<_Meta>(_onMeta);
    on<_Logout>(_onLogout);
  }

  Future<void> _onInit(_Init event, Emitter<AuthState> emit) async {
    if (kDebugMode && event.debugRoute != null) {
      router.pushAndPopUntil(event.debugRoute!, predicate: (_) => false);
      return;
    }

    emit(state.copyWith(
      initUsername: _authCache.login,
      initPassword: _authCache.password,
    ));

    if (state.initUsername.isNotEmpty && state.initPassword.isNotEmpty) {
      emit(state.copyWith(initPage: AuthPages.hasLogin));

      _authCache.setLogin(state.initUsername);
      _authCache.setPassword(state.initPassword);
    } else {
      emit(state.copyWith(
        initPage: _appCache.locale.isNotEmpty
            ? AuthPages.hasLanguage
            : AuthPages.noLanguage,
      ));
      _authCache.clear();
    }
  }

  Future<void> _onLogin(_Login event, Emitter<AuthState> emit) async {
    emit(state.copyWith(loginStatus: VarStatus.loading()));

    final result = await _facade.login(
      username: event.username,
      password: event.password,
    );

    result.fold(
      (l) {
        emit(state.copyWith(loginStatus: VarStatus.fail(l)));
      },
      (r) {
        _authCache.setToken(r);
        _authCache.setLogin(event.username);
        _authCache.setPassword(event.password);
        emit(state.copyWith(loginStatus: VarStatus.success()));
      },
    );
  }

  Future<void> _onUserInfo(_UserInfo event, Emitter<AuthState> emit) async {
    emit(state.copyWith(userInfoStatus: VarStatus.loading()));

    final result = await _facade.userInfo(requiredRemote: event.requiredRemote);

    result.fold(
      (l) {
        emit(state.copyWith(userInfoStatus: VarStatus.fail(l)));
      },
      (r) {
        emit(state.copyWith(userInfoStatus: VarStatus.success(), userInfo: r));
      },
    );
  }

  Future<void> _onMeta(_Meta event, Emitter<AuthState> emit) async {
    emit(state.copyWith(metaStatus: VarStatus.loading()));

    final result = await _facade.meta(requiredRemote: event.requiredRemote);

    result.fold(
      (l) {
        emit(state.copyWith(metaStatus: VarStatus.fail(l)));
      },
      (r) {
        AppGlobals.meta = r;
        emit(state.copyWith(metaStatus: VarStatus.success(), meta: r));
      },
    );
  }

  Future<void> _onLogout(_Logout event, Emitter<AuthState> emit) async {
    emit(state.copyWith(logoutStatus: VarStatus.loading()));

    final result = await _facade.logout();

    result.fold(
      (l) {
        emit(state.copyWith(logoutStatus: VarStatus.fail(l)));
      },
      (r) {
        emit(state.copyWith(logoutStatus: VarStatus.success()));
      },
    );
  }
}
