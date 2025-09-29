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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/action_buttons.dart';
import '../widgets/step_block_list.dart';

class StepTemplateView extends StatefulWidget {
  final BidModel bid;

  const StepTemplateView(this.bid, {super.key});

  @override
  State<StepTemplateView> createState() => _StepTemplateViewState();
}

class _StepTemplateViewState extends State<StepTemplateView> {
  final blockCount = 10;
  late final controller = PageController()..addListener(() => setState(() {}));
  late var template = context.read<TemplateBloc>().state.templateCache;
  late var canEdit = template.canEdit;
  late final stepIndexes = template.stepIndexes();
  var hasChanges = false;
  var checkValidate = false;

  int get page => controller.hasClients ? controller.page!.round() : 0;

  String? getError() => template.validateStep(page, stepIndexes);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
              title: Text(
                Words.cropMonitoring.str,
                textAlign: TextAlign.center,
                softWrap: true,
                maxLines: 2,
              ),
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
              actions: stepIndexes.isEmpty
                  ? []
                  : [
                      CupertinoButton(
                        minSize: 0,
                        padding: const EdgeInsets.all(4),
                        onPressed: page <= 0
                            ? null
                            : () {
                                if (hasChanges) {
                                  showError(
                                    context,
                                    Words.beforeSaveChanges.str,
                                  );
                                  return;
                                }
                                controller.animateToPage(
                                  page - 1,
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.linear,
                                );
                              },
                        child: const Icon(
                          CupertinoIcons.chevron_left,
                          size: 24,
                        ),
                      ),
                      Text(
                        stepIndexes.isNotEmpty ? "${page + 1}/$blockCount" : "",
                        style: TextStyle(
                          color: AppColors.gray.shade9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      CupertinoButton(
                        minSize: 0,
                        padding: const EdgeInsets.all(4),
                        onPressed: page >= 9
                            ? null
                            : () {
                                if (hasChanges) {
                                  showError(
                                    context,
                                    Words.beforeSaveChanges.str,
                                  );
                                  return;
                                }
                                if (getError() != null) {
                                  showError(
                                    context,
                                    Words.beforeSaveChanges.str,
                                  );
                                  return;
                                }

                                controller.animateToPage(
                                  page + 1,
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.linear,
                                );
                              },
                        child: const Icon(
                          CupertinoIcons.chevron_right,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: Builder(builder: (context) {
                    if (stepIndexes.isEmpty) {
                      return Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          Words.stepsNotFound.str,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return PageView.builder(
                      itemCount: blockCount,
                      controller: controller,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (_, i) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              StepBlockList(
                                bid: widget.bid,
                                template: template,
                                stepIndexes: stepIndexes,
                                blocStepIndex: i,
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
                        );
                      },
                    );
                  }),
                ),
                if (stepIndexes.isNotEmpty)
                  SafeArea(
                    child: Container(
                      width: double.infinity,
                      height: 74,
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 20, top: 8),
                      child: _Button(
                        text: page < 9
                            ? Words.saveAndContinue.str
                            : Words.saveAndEndMonitoring.str,
                        onPressed: () {
                          final errorTxt = getError();
                          if (errorTxt == null) {
                            hasChanges = false;
                            context
                                .read<TemplateBloc>()
                                .add(TemplateEvent.putTemplateCache(
                                  user: context.read<AuthBloc>().state.userInfo,
                                  bid: widget.bid,
                                  template: template,
                                ));

                            if (page < 9) {
                              controller.animateToPage(
                                page + 1,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.linear,
                              );
                            } else {
                              Navigator.of(context).pop();
                            }
                          } else {
                            checkValidate = true;
                            setState(() {});
                            showError(
                              context,
                              "${Words.happenError.str}\n$errorTxt",
                            );
                          }
                        },
                      ),
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

class _Button extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  const _Button({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minSize: 0,
      padding: EdgeInsets.zero,
      onPressed: onPressed,
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
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
