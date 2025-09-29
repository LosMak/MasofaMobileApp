part of 'device_info_bloc.dart';

@freezed
class DeviceInfoState with _$DeviceInfoState {
  const factory DeviceInfoState.initial({
    @Default(VarStatus()) VarStatus statusNotJailBroken,
    @Default(VarStatus()) VarStatus statusRealDevice,
    @Default(VarStatus()) VarStatus statusRealLocation,
    @Default(VarStatus()) VarStatus statusPackageInfo,
    PackageInfo? packageInfo,
  }) = _Initial;
}
