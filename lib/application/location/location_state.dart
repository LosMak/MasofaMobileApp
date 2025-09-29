part of 'location_bloc.dart';

@freezed
class LocationState with _$LocationState {
  const factory LocationState.initial({
    /// LocationEvent.init
    @Default(VarStatus()) VarStatus statusPosition,
    Position? position,

    /// LocationEvent.available
    @Default(VarStatus()) VarStatus statusAvailable,
  }) = _Initial;
}
