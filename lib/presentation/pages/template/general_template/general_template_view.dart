import 'package:dala_ishchisi/application/auth/auth_bloc.dart';
import 'package:dala_ishchisi/application/template/template_bloc.dart';
import 'package:dala_ishchisi/common/constants/app_globals.dart';
import 'package:dala_ishchisi/common/extensions/failure_extensions.dart';
import 'package:dala_ishchisi/common/extensions/message_extensions.dart';
import 'package:dala_ishchisi/common/extensions/template_extensions.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:dala_ishchisi/common/widgets/custom_appbar_back.dart';
import 'package:dala_ishchisi/common/widgets/custom_hide_keyboard.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:dala_ishchisi/domain/models/template_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/action_buttons.dart';
import '../widgets/sample_block_list.dart';

class GeneralTemplateView extends StatefulWidget {
  final BidModel bid;

  const GeneralTemplateView(this.bid, {super.key});

  @override
  State<GeneralTemplateView> createState() => _GeneralTemplateViewState();
}

class _GeneralTemplateViewState extends State<GeneralTemplateView> {
  late TemplateModel template;
  late bool canEdit;
  var hasChanges = false;
  var checkValidate = false;

  @override
  void initState() {
    template = context.read<TemplateBloc>().state.templateCache;
    canEdit = template.canEdit;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        if (hasChanges) {
          final result = await showDiscardChangesDialog(context);
          if (result == true) {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }
        }
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<TemplateBloc, TemplateState>(
            listenWhen: (old, e) =>
                old.putTemplateCacheStatus != e.putTemplateCacheStatus,
            listener: (context, state) {
              if (state.putTemplateCacheStatus.isFail) {
                showError(context, state.putTemplateCacheStatus.error);
              } else if (state.putTemplateCacheStatus.isSuccess) {
                context
                    .read<TemplateBloc>()
                    .add(TemplateEvent.templateCache(bidId: widget.bid.id));
                showMsg(Words.saved.str);
              }
            },
          ),
        ],
        child: CustomHideKeyboard(
          child: Scaffold(
            appBar: AppBar(
              title: Text(Words.generalData.str),
              leadingWidth: 100,
              automaticallyImplyLeading: false,
              leading: CustomAppbarBack(
                onPressed: () async {
                  if (hasChanges) {
                    final result = await showDiscardChangesDialog(context);
                    if (result == true) {
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SampleBlockList(
                          bid: widget.bid,
                          template: template,
                          canEdit: canEdit,
                          checkValidate: checkValidate,
                          onChanged: (t) {
                            if (template != t) {
                              hasChanges = true;
                              checkValidate = false;
                              template = t;
                            }
                            setState(() {});
                          },
                          lang: AppGlobals.lang,
                        ),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: _Buttons(
                    onCancel: () async {
                      if (hasChanges) {
                        final result = await showDiscardChangesDialog(context);
                        if (result == true) {
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    onSave: () {
                      final error = template.validateGeneral();
                      if (error == null) {
                        hasChanges = false;
                        context
                            .read<TemplateBloc>()
                            .add(TemplateEvent.putTemplateCache(
                              user: context.read<AuthBloc>().state.userInfo,
                              bid: widget.bid,
                              template: template,
                            ));
                      } else {
                        checkValidate = true;
                        setState(() {});
                        showError(context, "${Words.happenError.str}\n$error");
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> showDiscardChangesDialog(BuildContext context) {
    return showCupertinoModalPopup<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(Words.warning.str),
          content: Text(Words.discardChanges.str),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(Words.no.str),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(Words.yes.str),
            ),
          ],
        );
      },
    );
  }
}

class _Buttons extends StatelessWidget {
  final Function()? onCancel;
  final Function()? onSave;

  const _Buttons({this.onCancel, this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 74,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 8),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: CupertinoButton(
              minSize: 0,
              padding: EdgeInsets.zero,
              onPressed: onCancel,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: AppColors.gray.shade2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  Words.back.str,
                  style: TextStyle(
                    color: AppColors.gray.shade9,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: CupertinoButton(
              minSize: 0,
              padding: EdgeInsets.zero,
              onPressed: onSave,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: AppColors.gray.shade9,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  Words.save.str,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
