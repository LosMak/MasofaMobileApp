// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:dala_ishchisi/domain/models/template_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'archive_model.g.dart';
part 'archive_model.freezed.dart';

enum ArchiveSendStatus {
  sent,
  loading,
  unsent,
  none,
}

@freezed
class ArchiveModel with _$ArchiveModel {
  const factory ArchiveModel({
    @Default('') String id,
    @Default('') String path,
    @Default(0.0) double size,
    @Default(0.0) double progress,
    @Default(ArchiveSendStatus.none) ArchiveSendStatus status,
    @Default(BidModel()) BidModel bid,
    @Default(TemplateModel()) TemplateModel template,
  }) = _ArchiveModel;

  factory ArchiveModel.fromJson(Map<String, dynamic> json) =>
      _$ArchiveModelFromJson(json);
}
