part of 'location_bloc.dart';

@freezed
class LocationEvent with _$LocationEvent {
  const factory LocationEvent.init() = _init;

  const factory LocationEvent.available(PolygonModel polygon) = _available;

  const factory LocationEvent.distance(Position position) = _distance;
}
