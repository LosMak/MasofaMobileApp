part of 'template_bloc.dart';

@freezed
class TemplateEvent with _$TemplateEvent {
  const factory TemplateEvent.template({
    required BidModel bid,
    @Default(false) bool requiredRemote,
  }) = _Template;

  const factory TemplateEvent.deleteTemplate(BidModel bid) = _DeleteTemplate;

  const factory TemplateEvent.templateCache({required String bidId}) =
      _TemplateCache;

  const factory TemplateEvent.putTemplateCache({
    required UserInfoModel user,
    required BidModel bid,
    required TemplateModel template,
  }) = _PutTemplateCache;

  const factory TemplateEvent.uploadTemplate({
    required BidModel bid,
    required TemplateModel template,
  }) = _UploadTemplate;

  

  // To test zip file details | not show in release
  const factory TemplateEvent.shareTemplate({required BidModel bid}) =
      _ShareTemplate;
}
