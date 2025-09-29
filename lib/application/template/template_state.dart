part of 'template_bloc.dart';

@freezed
class TemplateState with _$TemplateState {
  const factory TemplateState.initial({
    /// TemplateEvent.template
    @Default(VarStatus()) VarStatus templateStatus,
    @Default(TemplateModel()) TemplateModel template,

    /// TemplateEvent.deleteTemplate
    @Default(VarStatus()) VarStatus deleteTemplateStatus,

    /// TemplateEvent.templateCache
    @Default(VarStatus()) VarStatus templateCacheStatus,
    @Default(TemplateModel()) TemplateModel templateCache,

    /// TemplateEvent.putTemplateCache
    @Default(VarStatus()) VarStatus putTemplateCacheStatus,

    /// TemplateEvent.uploadTemplate
    @Default(VarStatus()) VarStatus uploadTemplateStatus,
    @Default(0.0) double uploadProgress,

    /// TemplateEvent.shareTemplate
    @Default(VarStatus()) VarStatus shareTemplateStatus,
  }) = _Initial;
}
