part of 'auth_bloc.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.init({
    PageRouteInfo? debugRoute, // for debug, first push this route
  }) = _Init;

  const factory AuthEvent.login({
    required String username,
    required String password,
  }) = _Login;

  const factory AuthEvent.userInfo({
    @Default(false) bool requiredRemote,
  }) = _UserInfo;

  const factory AuthEvent.meta({@Default(false) bool requiredRemote}) = _Meta;

  const factory AuthEvent.logout() = _Logout;
}
