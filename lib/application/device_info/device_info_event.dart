part of 'device_info_bloc.dart';

@freezed
class DeviceInfoEvent with _$DeviceInfoEvent {
  const factory DeviceInfoEvent.checkNotJailBroken() = _checkNotJailBroken;

  const factory DeviceInfoEvent.checkRealDevice() = _checkRealDevice;

  const factory DeviceInfoEvent.checkRealLocation() = _checkRealLocation;

  const factory DeviceInfoEvent.getProjectInfo() = _getProjectInfo;
}
