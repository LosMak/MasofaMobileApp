part of 'network_info_bloc.dart';

@freezed
class NetworkInfoState with _$NetworkInfoState {
  const factory NetworkInfoState.initial({@Default(false) bool isConnected}) =
      _Initial;
}
