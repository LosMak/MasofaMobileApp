import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_info_model.freezed.dart';
part 'user_info_model.g.dart';

/// Enum for user roles
enum UserRole {
  @JsonValue('Operator')
  operator,
  @JsonValue('Administrator')
  admin,
  @JsonValue('Foreman')
  foreman,
  @JsonValue('Worker')
  worker,
}

@freezed
class UserInfoModel with _$UserInfoModel {
  const factory UserInfoModel({
    @Default('') @JsonKey(name: 'sub') String id,
    @Default('') String email,
    @Default(false) @JsonKey(name: 'email_verified') bool emailVerified,
    @Default([]) List<UserRole> role,
  }) = _UserInfoModel;

  factory UserInfoModel.fromJson(Map<String, dynamic> json) =>
      _$UserInfoModelFromJson(json);
}
