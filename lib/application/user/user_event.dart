part of 'user_bloc.dart';

@freezed
class UserEvent with _$UserEvent {
  const factory UserEvent.users({
    @Default(false) bool clearCache,
    @Default(true) bool requiredRemote,
    required String parentId,
  }) = _Users;
}
