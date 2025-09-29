import 'package:dala_ishchisi/common/constants/app_globals.dart';
import 'package:dala_ishchisi/domain/models/meta_model.dart';

class UserModel {
  final String id;
  final String parentId;
  final String name;
  final bool active;
  final String typeId;
  final TypeModel type;

  const UserModel({
    this.id = "",
    this.parentId = "",
    this.name = "",
    this.active = false,
    this.typeId = "",
    this.type = const TypeModel(),
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final typeIndex =
        AppGlobals.meta.userTypes.indexWhere((e) => e.id == json["typeId"]);

    return UserModel(
      id: json["id"] ?? "",
      parentId: json["parentId"] ?? "",
      name: json["name"] ?? "",
      active: json["active"] ?? false,
      typeId: json["typeId"] ?? "",
      type: typeIndex != -1
          ? AppGlobals.meta.userTypes[typeIndex]
          : const TypeModel(),
    );
  }
}
