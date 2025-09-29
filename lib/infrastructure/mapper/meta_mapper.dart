import 'package:api_client_dictionaries/api_client_dictionaries.dart';
import 'package:built_collection/built_collection.dart';
import 'package:dala_ishchisi/domain/models/meta_model.dart';

class MetaMapper {
  static TARGET transform<SOURCE, TARGET>(SOURCE model) {
    if (model is RegionModel) {
      return TypeModel(
        id: model.id ?? '',
        name: model.nameRu ?? '',
        nameEn: model.nameEn ?? '',
        nameRu: model.nameRu ?? '',
      ) as TARGET;
    }
    if (model is CropModel) {
      return TypeModel(
        id: model.id ?? '',
        name: model.nameRu ?? '',
        nameEn: model.nameEn ?? '',
        nameRu: model.nameRu ?? '',
      ) as TARGET;
    }
    if (model is BidStateModel) {
      return TypeModel(
        id: model.id ?? '',
        name: model.nameRu ?? '',
        nameEn: model.nameEn ?? '',
        nameRu: model.nameRu ?? '',
      ) as TARGET;
    }
    if (model is BidTypeModel) {
      return TypeModel(
        id: model.id ?? '',
        name: model.nameRu ?? '',
        nameEn: model.nameEn ?? '',
        nameRu: model.nameRu ?? '',
      ) as TARGET;
    }
    if (model is BidContentModel) {
      return TypeModel(
        id: model.id ?? '',
        name: model.nameRu ?? '',
        nameEn: model.nameEn ?? '',
        nameRu: model.nameRu ?? '',
      ) as TARGET;
    }
    if (model is DiseaseModel) {
      return CropTypeModel(
        id: model.id ?? '',
        name: model.nameRu ?? '',
        nameEn: model.nameEn ?? '',
        cropId: model.cropId ?? '',
      ) as TARGET;
    }
    if (model is PesticideModel) {
      return CropTypeModel(
        id: model.id ?? '',
        name: model.nameRu ?? '',
        nameEn: model.nameEn ?? '',
        cropId: '',
      ) as TARGET;
    }
    if (model is SoilTypeModel) {
      return TypeModel(
        id: model.id ?? '',
        name: model.nameRu ?? '',
        nameRu: model.nameRu ?? '',
        nameEn: model.nameEn ?? '',
      ) as TARGET;
    }

    if (model is WaterResourceModel) {
      return TypeModel(
        id: model.id ?? '',
        name: model.nameRu ?? '',
        nameRu: model.nameRu ?? '',
        nameEn: model.nameEn ?? '',
      ) as TARGET;
    }
    if (model is PersonModel) {
      return TypeModel(
        id: model.userId ?? '',
        name: model.nameRu ?? '',
        nameRu: model.nameRu ?? '',
        nameEn: model.nameEn ?? '',
      ) as TARGET;
    }
    throw UnimplementedError();
  }

  static List<TARGET> transformList<SOURCE, TARGET>(BuiltList<SOURCE>? list) {
    if (list == null) {
      return [];
    }
    return list.map((e) => transform<SOURCE, TARGET>(e)).toList();
  }
}
