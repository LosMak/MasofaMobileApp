import 'package:dala_ishchisi/common/constants/app_globals.dart';

import 'meta_model.dart';
import 'polygon_model.dart';

enum BidStateType {
  created,
  active,
  inProgress,
  finished,
  rejected,
  cancelled,
  archive,
  none,
}

class BidModel {
  final String id;
  final String createAt;
  final int status;
  final String lastUpdateAt;
  final String parentId;
  final String createUserId;
  final String createDate;
  final String modifyUser;
  final String modifyDate;
  final bool active;
  final String bidTypeId;
  final TypeModel bidType;
  final BidStateType bidState;
  final String foremanId;
  final String workerId;
  final String startDate;
  final String deadlineDate;
  final String endDate;
  final String fieldPlantingDate;
  final int number;
  final String fieldId;
  final String regionId;
  final String bidTemplateId;
  final String fileResultId;
  final String lastUpdateUser;
  final TypeModel region;
  final ParentTypeModel district;
  final String cropId;
  final TypeModel crop;
  final String comment;
  final String customer;
  final String description;
  final String varietyId;
  final String contourId;
  final String contentId;
  final TypeModel content;
  final double lat;
  final double lng;
  final bool published;
  final bool cancelled;
  final PolygonModel geoJson;

  const BidModel({
    this.id = "",
    this.createUserId = "",
    this.createDate = "",
    this.modifyUser = "",
    this.modifyDate = "",
    this.active = false,
    this.bidTypeId = "",
    this.bidType = const TypeModel(),
    this.bidState = BidStateType.none,
    this.foremanId = "",
    this.workerId = "",
    this.startDate = "",
    this.deadlineDate = "",
    this.endDate = "",
    this.fieldPlantingDate = "",
    this.number = 0,
    this.fieldId = "",
    this.regionId = "",
    this.region = const TypeModel(),
    this.district = const ParentTypeModel(),
    this.cropId = "",
    this.bidTemplateId = "",
    this.crop = const TypeModel(),
    this.comment = "",
    this.description = "",
    this.varietyId = "",
    this.contourId = "",
    this.contentId = "",
    this.content = const TypeModel(),
    this.lat = 0,
    this.lng = 0,
    this.published = false,
    this.cancelled = false,
    this.geoJson = const PolygonModel(),
    this.createAt = "",
    this.customer = "",
    this.fileResultId = "",
    this.lastUpdateAt = "",
    this.parentId = "",
    this.lastUpdateUser = "",
    this.status = 0,
  });

  factory BidModel.fromJson(Map<String, dynamic> json) {
    final bidTypeIndex =
        AppGlobals.meta.bidTypes.indexWhere((e) => e.id == json["bidTypeId"]);
    final cropIndex =
        AppGlobals.meta.crops.indexWhere((e) => e.id == json["cropId"]);
    final districtIndex =
        AppGlobals.meta.districts.indexWhere((e) => e.id == json["regionId"]);
    final regionIndex = districtIndex == -1
        ? -1
        : AppGlobals.meta.regions.indexWhere(
            (e) => e.id == AppGlobals.meta.districts[districtIndex].parentId);
    final contentIndex =
        AppGlobals.meta.contents.indexWhere((e) => e.id == json["contentId"]);
    // dynamic geoJson;
    // if (json["geoJson"] != null) {
    // geoJson = jsonDecode(json["geoJson"])['geometry'];
    // print("GEO JSON: ${jsonEncode(geoJson)}");
    // }

    return BidModel(
      id: json["id"] ?? "",
      createUserId: json["createUser"] ?? "",
      createDate: fromJsonDate(json["createDate"]),
      modifyUser: json["modifyUser"] ?? "",
      modifyDate: fromJsonDate(json["modifyDate"]),
      active: json["active"] ?? false,
      bidTypeId: json["bidTypeId"] ?? "",
      bidType: bidTypeIndex != -1
          ? AppGlobals.meta.bidTypes[bidTypeIndex]
          : const TypeModel(),
      bidState: json["bidState"] ?? "",
      foremanId: json["foremanId"] ?? "",
      workerId: json["workerId"] ?? "",
      startDate: fromJsonDate(json["startDate"]),
      deadlineDate: fromJsonDate(json["deadlineDate"]),
      endDate: fromJsonDate(json["endDate"]),
      fieldPlantingDate: fromJsonDate(json["fieldPlantingDate"]),
      number: json["number"] ?? 0,
      fieldId: json["fieldId"] ?? "",
      regionId: json["regionId"] ?? "",
      region: regionIndex != -1
          ? AppGlobals.meta.regions[regionIndex]
          : const TypeModel(),
      district: districtIndex != -1
          ? AppGlobals.meta.districts[districtIndex]
          : const ParentTypeModel(),
      cropId: json["cropId"] ?? "",
      crop: cropIndex != -1
          ? AppGlobals.meta.crops[cropIndex]
          : const TypeModel(),
      bidTemplateId: json["bidTemplateId"],
      comment: json["comment"] ?? "",
      description: json["description"] ?? "",
      varietyId: json["varietyId"] ?? "",
      contourId: json["contourId"] ?? "",
      contentId: json["contentId"] ?? "",
      content: contentIndex != -1
          ? AppGlobals.meta.contents[contentIndex]
          : const TypeModel(),
      lat: json["lat"]?.toDouble() ?? 0.0,
      lng: json["lng"]?.toDouble() ?? 0.0,
      published: json["published"] ?? false,
      cancelled: json["cancelled"] ?? false,
      createAt: json["createAt"] ?? "",
      customer: json["customer"] ?? "",
      fileResultId: json["fileResultId"] ?? "",
      lastUpdateAt: json["lastUpdateAt"] ?? "",
      parentId: json["parentId"] ?? "",
      status: json["status"] ?? 0,
      lastUpdateUser: json["lastUpdateUser"],
      // geoJson: geoJson == null
      //     ? const PolygonModel()
      //     : PolygonModel.fromJson(geoJson),
    );
  }

  static String fromJsonDate(String? data) {
    if (data == null) return '';
    if (data.isEmpty) return '';
    if (data.contains('0001-01-01')) return '';
    return data;
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "createUser": createUserId,
      "createDate": createDate,
      "modifyUser": modifyUser,
      "modifyDate": modifyDate,
      "active": active,
      "bidTypeId": bidTypeId,
      "bidState": bidState,
      "foremanId": foremanId,
      "workerId": workerId,
      "startDate": startDate,
      "deadlineDate": deadlineDate,
      "endDate": endDate,
      "fieldPlantingDate": fieldPlantingDate,
      "number": number,
      "fieldId": fieldId,
      "regionId": regionId,
      "cropId": cropId,
      "bidTemplateId": bidTemplateId,
      "comment": comment,
      "description": description,
      "varietyId": varietyId,
      "contourId": contourId,
      "contentId": contentId,
      "lat": lat,
      "lng": lng,
      "published": published,
      "cancelled": cancelled,
      "createAt": createAt,
      "customer": customer,
      "fileResultId": fileResultId,
      "lastUpdateAt": lastUpdateAt,
      "parentId": parentId,
      "status": status,
      "lastUpdateUser": lastUpdateUser,
      "geoJson": geoJson.toJson(),
    };
  }

  BidModel copyWith({
    String? id,
    String? createAt,
    int? status,
    String? lastUpdateAt,
    String? parentId,
    String? createUserId,
    String? createDate,
    String? modifyUser,
    String? modifyDate,
    bool? active,
    String? bidTypeId,
    TypeModel? bidType,
    BidStateType? bidState,
    String? foremanId,
    String? workerId,
    String? startDate,
    String? deadlineDate,
    String? endDate,
    String? fieldPlantingDate,
    int? number,
    String? fieldId,
    String? regionId,
    String? bidTemplateId,
    String? fileResultId,
    String? lastUpdateUser,
    TypeModel? region,
    ParentTypeModel? district,
    String? cropId,
    TypeModel? crop,
    String? comment,
    String? customer,
    String? description,
    String? varietyId,
    String? contourId,
    String? contentId,
    TypeModel? content,
    double? lat,
    double? lng,
    bool? published,
    bool? cancelled,
    PolygonModel? geoJson,
  }) {
    return BidModel(
      id: id ?? this.id,
      createAt: createAt ?? this.createAt,
      status: status ?? this.status,
      lastUpdateAt: lastUpdateAt ?? this.lastUpdateAt,
      parentId: parentId ?? this.parentId,
      createUserId: createUserId ?? this.createUserId,
      createDate: createDate ?? this.createDate,
      modifyUser: modifyUser ?? this.modifyUser,
      modifyDate: modifyDate ?? this.modifyDate,
      active: active ?? this.active,
      bidTypeId: bidTypeId ?? this.bidTypeId,
      bidType: bidType ?? this.bidType,
      bidState: bidState ?? this.bidState,
      foremanId: foremanId ?? this.foremanId,
      workerId: workerId ?? this.workerId,
      startDate: startDate ?? this.startDate,
      deadlineDate: deadlineDate ?? this.deadlineDate,
      endDate: endDate ?? this.endDate,
      fieldPlantingDate: fieldPlantingDate ?? this.fieldPlantingDate,
      number: number ?? this.number,
      fieldId: fieldId ?? this.fieldId,
      regionId: regionId ?? this.regionId,
      bidTemplateId: bidTemplateId ?? this.bidTemplateId,
      fileResultId: fileResultId ?? this.fileResultId,
      lastUpdateUser: lastUpdateUser ?? this.lastUpdateUser,
      region: region ?? this.region,
      district: district ?? this.district,
      cropId: cropId ?? this.cropId,
      crop: crop ?? this.crop,
      comment: comment ?? this.comment,
      customer: customer ?? this.customer,
      description: description ?? this.description,
      varietyId: varietyId ?? this.varietyId,
      contourId: contourId ?? this.contourId,
      contentId: contentId ?? this.contentId,
      content: content ?? this.content,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      published: published ?? this.published,
      cancelled: cancelled ?? this.cancelled,
      geoJson: geoJson ?? this.geoJson,
    );
  }
}
