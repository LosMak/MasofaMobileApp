import 'package:api_client_crop/api_client_crop.dart' as api;
import 'package:built_collection/built_collection.dart';
import 'package:dala_ishchisi/common/constants/app_globals.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:dala_ishchisi/domain/models/meta_model.dart';
import 'package:easy_localization/easy_localization.dart';

class BidMapper {
  static String get _emptyGuid => '00000000-0000-0000-0000-000000000000';

  static BidModel transform(api.BidModel? model) {
    if (model == null) {
      return const BidModel();
    }
    return BidModel(
      id: model.id ?? '',
      comment: model.comment ?? '',
      description: model.description ?? '',
      bidState: fromBidStateTypeModelToBidStateType(model.bidState),
      bidTypeId: model.bidTypeId ?? '',
      bidType: _bidType(model.bidTypeId ?? ''),
      workerId: model.workerId ?? '',
      foremanId: model.foremanId ?? '',
      regionId: model.regionId ?? '',
      fieldId: model.fieldId ?? '',
      cropId: model.cropId ?? '',
      bidTemplateId: model.bidTemplateId ?? '',
      crop: _crops(model.cropId ?? ''),
      varietyId: model.varietyId ?? '',
      deadlineDate: _fromDateTimeToString(model.deadlineDate),
      startDate: _fromDateTimeToString(model.startDate),
      endDate: _fromDateTimeToString(model.endDate),
      fieldPlantingDate: _fromDateTimeToString(model.fieldPlantingDate),
      createAt: _fromDateTimeToString(model.createAt),
      lastUpdateAt: _fromDateTimeToString(model.lastUpdateAt),
      lat: model.lat ?? 0.0,
      lng: model.lng ?? 0.0,
      number: model.number ?? 0,
    );
  }

  static api.BidModel reverseTransform(BidModel? model) {
    if (model == null) {
      return api.BidModel();
    }
    final updateModel = api.BidModel(
      (b) => b
        ..id = model.id // required
        ..comment = _nullIfEmpty(model.comment) ?? ""
        ..description = _nullIfEmpty(model.description)
        ..bidState =
            fromBidStateTypeToBidStateTypeModel(model.bidState) // required
        ..bidTypeId = _nullIfEmpty(model.bidTypeId) ?? _emptyGuid // required
        ..workerId = _nullIfEmpty(model.workerId) ?? _emptyGuid
        ..foremanId = _nullIfEmpty(model.foremanId) ?? _emptyGuid
        ..regionId = _nullIfEmpty(model.regionId) ?? _emptyGuid
        ..fieldId = _nullIfEmpty(model.fieldId) ?? _emptyGuid
        ..bidTemplateId =
            _nullIfEmpty(model.bidTemplateId) ?? _emptyGuid // required
        ..cropId = _nullIfEmpty(model.cropId) ?? _emptyGuid
        ..varietyId = _nullIfEmpty(model.varietyId) ?? _emptyGuid
        ..deadlineDate = _fromStringToDateTime(model.deadlineDate)
        ..startDate = _fromStringToDateTime(model.startDate)
        ..endDate = _fromStringToDateTime(model.endDate)
        ..fieldPlantingDate = _fromStringToDateTime(model.fieldPlantingDate)
        ..customer = _nullIfEmpty(model.customer)
        ..fileResultId = _nullIfEmpty(model.fileResultId) ?? _emptyGuid
        ..parentId = _nullIfEmpty(model.parentId) ?? _emptyGuid
        ..createUser =
            _nullIfEmpty(model.createUserId) ?? _emptyGuid // required
        ..lastUpdateUser =
            _nullIfEmpty(model.lastUpdateUser) ?? _emptyGuid // required
        ..lastUpdateAt = _fromStringToDateTime(model.lastUpdateAt) // required
        ..createAt = _fromStringToDateTime(model.createAt) // required
        ..lat = model.lat
        ..lng = model.lng
        ..status = _fromIntToStatusTypeModel(model.status) // required
        ..number = model.number, // required
    );
    return updateModel;
  }

  static BidStateType fromBidStateTypeModelToBidStateType(
      api.BidStateTypeModel? value) {
    if (value == null) {
      return BidStateType.none;
    }
    return switch (value) {
      api.BidStateTypeModel.number0 => BidStateType.created,
      api.BidStateTypeModel.number1 => BidStateType.active,
      api.BidStateTypeModel.number2 => BidStateType.inProgress,
      api.BidStateTypeModel.number3 => BidStateType.finished,
      api.BidStateTypeModel.number4 => BidStateType.rejected,
      api.BidStateTypeModel.number5 => BidStateType.cancelled,
      _ => BidStateType.none,
    };
  }

  static api.BidStateTypeModel fromBidStateTypeToBidStateTypeModel(
      BidStateType value) {
    return switch (value) {
      BidStateType.created => api.BidStateTypeModel.number0,
      BidStateType.active => api.BidStateTypeModel.number1,
      BidStateType.inProgress => api.BidStateTypeModel.number2,
      BidStateType.finished => api.BidStateTypeModel.number3,
      BidStateType.rejected => api.BidStateTypeModel.number4,
      BidStateType.cancelled => api.BidStateTypeModel.number5,
      _ => api.BidStateTypeModel.number2,
    };
  }

  static int fromBidStateTypeModelToInt(BidStateType value) {
    return switch (value) {
      BidStateType.created => 0,
      BidStateType.active => 1,
      BidStateType.inProgress => 2,
      BidStateType.finished => 3,
      BidStateType.rejected => 4,
      BidStateType.cancelled => 5,
      _ => 2,
    };
  }

  static api.StatusTypeModel _fromIntToStatusTypeModel(int value) {
    return api.StatusTypeModel.values.elementAt(value);
  }

  static List<BidModel> transformList(BuiltList<api.BidModel>? list) {
    if (list == null) {
      return [];
    }
    return list.map((e) => transform(e)).toList();
  }

  static String? _nullIfEmpty(String value) {
    if (value.isEmpty) {
      return null;
    }
    return value;
  }

  static String _fromDateTimeToString(DateTime? date) {
    if (date == null) {
      return '';
    }
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }

  static DateTime? _fromStringToDateTime(String date) {
    if (date.isEmpty) {
      return null;
    }
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.parse(date).toUtc();
  }

  static TypeModel _bidType(String bidTypeId) {
    final bidTypeIndex =
        AppGlobals.meta.bidTypes.indexWhere((e) => e.id == bidTypeId);
    return bidTypeIndex != -1
        ? AppGlobals.meta.bidTypes[bidTypeIndex]
        : const TypeModel();
  }

  static TypeModel _bidState(String bidStateId) {
    final bidStateIndex =
        AppGlobals.meta.bidStates.indexWhere((e) => e.id == bidStateId);
    return bidStateIndex != -1
        ? AppGlobals.meta.bidStates[bidStateIndex]
        : const TypeModel();
  }

  static TypeModel _crops(String cropId) {
    final cropIndex = AppGlobals.meta.crops.indexWhere((e) => e.id == cropId);
    return cropIndex != -1
        ? AppGlobals.meta.crops[cropIndex]
        : const TypeModel();
  }

  static ParentTypeModel _district(String regionId) {
    final districtIndex =
        AppGlobals.meta.crops.indexWhere((e) => e.id == regionId);
    return districtIndex != -1
        ? AppGlobals.meta.districts[districtIndex]
        : const ParentTypeModel();
  }

  static TypeModel _region(int districtIndex) {
    final regionIndex = districtIndex == -1
        ? -1
        : AppGlobals.meta.regions.indexWhere(
            (e) => e.id == AppGlobals.meta.districts[districtIndex].parentId);
    return regionIndex != -1
        ? AppGlobals.meta.regions[regionIndex]
        : const TypeModel();
  }

  static TypeModel _content(String contentId) {
    final contentIndex =
        AppGlobals.meta.contents.indexWhere((e) => e.id == contentId);
    return contentIndex != -1
        ? AppGlobals.meta.contents[contentIndex]
        : const TypeModel();
  }
}
