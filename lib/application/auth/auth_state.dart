part of 'auth_bloc.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial({
    /// AuthEvent.init
    @Default(AuthPages.none) AuthPages initPage,
    @Default('') String initUsername,
    @Default('') String initPassword,

    /// AuthEvent.login
    @Default(VarStatus()) VarStatus loginStatus,

    /// AuthEvent.userInfo
    @Default(VarStatus()) VarStatus userInfoStatus,
    @Default(UserInfoModel()) UserInfoModel userInfo,

    /// AuthEvent.meta
    @Default(VarStatus()) VarStatus metaStatus,
    @Default(MetaModel()) MetaModel meta,

    /// AuthEvent.logout
    @Default(VarStatus()) VarStatus logoutStatus,
  }) = _Initial;
}

enum AuthPages { none, noLanguage, hasLanguage, hasLogin }
