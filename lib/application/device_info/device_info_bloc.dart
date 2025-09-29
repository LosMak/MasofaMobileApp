import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:safe_device/safe_device.dart';

import '../var_status.dart';

part 'device_info_bloc.freezed.dart';
part 'device_info_event.dart';
part 'device_info_state.dart';

/// This bloc is for using to get not_jail_broken, real_device, real_location and project_info
///
/// Examples:
/// [wrap BlocProvider] and [to check up details]
/// ```dart
/// BlocProvider(
///    create: (_) => di<DeviceInfoBloc>()
///      ..add(const DeviceInfoEvent.checkNotJailBroken())
///      ..add(const DeviceInfoEvent.checkRealDevice())
///      ..add(const DeviceInfoEvent.checkRealLocation())
///      ..add(const DeviceInfoEvent.getProjectInfo()),
/// ),
/// ```
/// [to get real_device with BlocBuilder], other constants like this
/// ```dart
/// return BlocBuilder<DeviceInfoBloc, DeviceInfoState>(
///    builder: (context, state) {
///      return Scaffold(
///        appBar: AppBar(title: Text('${state.statusRealDevice.isSuccess}')),
///      );
///    },
/// );
/// ```
@Injectable()
class DeviceInfoBloc extends Bloc<DeviceInfoEvent, DeviceInfoState> {
  DeviceInfoBloc() : super(const DeviceInfoState.initial()) {
    if (kIsWeb) {
      return;
    }
    on<_checkNotJailBroken>(_onCheckNotJailBroken);
    on<_checkRealDevice>(_onCheckRealDevice);
    on<_checkRealLocation>(_onCheckRealLocation);
    on<_getProjectInfo>(_onGetProjectInfo);
  }

  Future<void> _onCheckNotJailBroken(
    _checkNotJailBroken event,
    Emitter<DeviceInfoState> emit,
  ) async {
    emit(state.copyWith(statusNotJailBroken: VarStatus.loading()));
    final value = await SafeDevice.isJailBroken;
    if (value) {
      emit(
        state.copyWith(statusNotJailBroken: VarStatus.fail('JailBroken found')),
      );
    } else {
      emit(state.copyWith(statusNotJailBroken: VarStatus.success()));
    }
  }

  Future<void> _onCheckRealDevice(
    _checkRealDevice event,
    Emitter<DeviceInfoState> emit,
  ) async {
    emit(state.copyWith(statusRealDevice: VarStatus.loading()));
    final value = await SafeDevice.isRealDevice;
    if (value) {
      emit(state.copyWith(statusRealDevice: VarStatus.success()));
    } else {
      emit(
        state.copyWith(
          statusRealDevice: VarStatus.fail('This is not real device!'),
        ),
      );
    }
  }

  Future<void> _onCheckRealLocation(
    _checkRealLocation event,
    Emitter<DeviceInfoState> emit,
  ) async {
    emit(state.copyWith(statusRealLocation: VarStatus.loading()));
    final value = await SafeDevice.isMockLocation;
    if (value) {
      emit(
        state.copyWith(
          statusRealLocation: VarStatus.fail('Location is not real!'),
        ),
      );
    } else {
      emit(state.copyWith(statusRealLocation: VarStatus.success()));
    }
  }

  Future<void> _onGetProjectInfo(
    _getProjectInfo event,
    Emitter<DeviceInfoState> emit,
  ) async {
    emit(state.copyWith(statusPackageInfo: VarStatus.loading()));
    final value = await PackageInfo.fromPlatform();
    emit(
      state.copyWith(
        statusPackageInfo: VarStatus.success(),
        packageInfo: value,
      ),
    );
  }
}
