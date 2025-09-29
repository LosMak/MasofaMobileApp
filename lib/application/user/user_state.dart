part of 'user_bloc.dart';

@freezed
class UserState with _$UserState {
  const factory UserState.initial({
    /// UserEvent.users
    @Default(VarStatus()) VarStatus usersStatus,
    @Default([]) List<UserModel> users,
  }) = _Initial;
}
