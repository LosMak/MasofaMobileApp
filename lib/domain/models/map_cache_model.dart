import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_cache_model.freezed.dart';

@freezed
class MapCacheModel with _$MapCacheModel {
  const factory MapCacheModel({
    @Default('') String filename,
    required Uint8List bytes,
  }) = _MapCacheModel;
}
