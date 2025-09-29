part of 'network_info_bloc.dart';

@freezed
class NetworkInfoEvent with _$NetworkInfoEvent {
  const factory NetworkInfoEvent.init() = _init;

  const factory NetworkInfoEvent.change(bool isConnected) = _change;

  const factory NetworkInfoEvent.forceConnectionCheck() = _forceConnectionCheck;
}
