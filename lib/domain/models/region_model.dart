import 'package:freezed_annotation/freezed_annotation.dart';

part 'region_model.freezed.dart';
part 'region_model.g.dart';

@freezed
class RegionModel with _$RegionModel {
  const factory RegionModel({
    required String regionId,
    required int fileSizeInMegabytes,
    required DateTime lastUpdateUtc,
    @Default('') String nameRu,
    @Default('') String nameEn,
    @Default('') String nameUz,
  }) = _RegionModel;

  factory RegionModel.fromJson(Map<String, dynamic> json) =>
      _$RegionModelFromJson(json);
}
