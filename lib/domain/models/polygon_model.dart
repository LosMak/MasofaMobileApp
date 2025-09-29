import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'polygon_model.freezed.dart';
part 'polygon_model.g.dart';

@freezed
class PolygonModel with _$PolygonModel {
  const factory PolygonModel({
    @Default('') String type,
    @Default([]) List<List<List<({double lng, double lat})>>> coordinates,
  }) = _PolygonModel;

  factory PolygonModel.fromJson(Map<String, dynamic> json) =>
      _$PolygonModelFromJson(json);

  factory PolygonModel.fromString(String? str) {
    if ((str ?? '').isNotEmpty) {
      final json = jsonDecode(str!);
      final List<List<List<({double lng, double lat})>>> list = [];
      for (var polygon in (json['coordinates'] ?? [])) {
        final List<List<({double lng, double lat})>> polygonCoordinates = [];
        for (var ring in (polygon ?? [])) {
          final List<({double lng, double lat})> ringPoints = [];
          for (var point in (ring ?? [])) {
            if ((point as List).length == 2) {
              ringPoints.add((lng: point[0], lat: point[1]));
            }
          }
          polygonCoordinates.add(ringPoints);
        }
        list.add(polygonCoordinates);
      }
      return PolygonModel(type: json['type'] ?? '', coordinates: list);
    }
    return const PolygonModel();
  }
}
