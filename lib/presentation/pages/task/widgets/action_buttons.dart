import 'package:dala_ishchisi/application/auth/auth_bloc.dart';
import 'package:dala_ishchisi/application/bid/bid_bloc.dart';
import 'package:dala_ishchisi/application/device_info/device_info_bloc.dart';
import 'package:dala_ishchisi/application/template/template_bloc.dart';
import 'package:dala_ishchisi/common/constants/app_globals.dart';
import 'package:dala_ishchisi/common/extensions/failure_extensions.dart';
import 'package:dala_ishchisi/common/extensions/int_extensions.dart';
import 'package:dala_ishchisi/common/extensions/position_extension.dart';
import 'package:dala_ishchisi/common/extensions/template_extensions.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:dala_ishchisi/domain/models/template_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  void onStart(
    BuildContext context,
    BidModel bid,
    TemplateModel templateCache,
  ) {
    final safeDevice =
        context.read<DeviceInfoBloc>().state.statusRealDevice.isSuccess &&
            context.read<DeviceInfoBloc>().state.statusRealLocation.isSuccess;

    if (kReleaseMode && safeDevice && AppGlobals.position != null) {
      if (AppGlobals.position!.isNear(bid.position)) {
        context.read<BidBloc>().add(
              BidEvent.updateBidStatus(
                bid: bid,
                bidStateType: BidStateType.inProgress,
              ),
            );

        context.read<TemplateBloc>().add(
              TemplateEvent.putTemplateCache(
                user: context.read<AuthBloc>().state.userInfo,
                bid: bid,
                template: templateCache.updateTemplateStartDate(),
              ),
            );

        return;
      }
      final distance =
          AppGlobals.position!.distanceTo(bid.position).toReadableDistance();
      final msg = Words.farFromContour.str.replaceAll('&distance', distance);
      showError(context, msg);

      return;
    }
    context.read<BidBloc>().add(
          BidEvent.updateBidStatus(
            bid: bid,
            bidStateType: BidStateType.inProgress,
          ),
        );

    context.read<TemplateBloc>().add(
          TemplateEvent.putTemplateCache(
            user: context.read<AuthBloc>().state.userInfo,
            bid: bid,
            template: templateCache.updateTemplateStartDate(),
          ),
        );
  }

  void onUpload(
    BuildContext context,
    BidModel bid,
    TemplateModel templateCache,
  ) {
    if (templateCache.validateGeneral() == null &&
        templateCache.validateSteps(templateCache.stepIndexes()) == null) {
      context.read<TemplateBloc>().add(TemplateEvent.uploadTemplate(
            bid: bid,
            template: templateCache,
          ));
    } else {
      showError(context, Words.noInfo.str);
    }
  }

  Future<bool?> showUploadDialog(BuildContext context) {
    return showCupertinoModalPopup<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(Words.warning.str),
          content: Text(Words.confirmationSendingBid.str),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(Words.no.str),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(Words.yes.str),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BidBloc, BidState>(
      builder: (context, bidState) {
        return BlocBuilder<TemplateBloc, TemplateState>(
          builder: (context, state) {
            final bidStateType = bidState.bid.bidState;

            if (bidStateType == BidStateType.finished ||
                bidStateType == BidStateType.rejected ||
                bidStateType == BidStateType.cancelled) {
              return const SizedBox();
            }

            if (!state.templateCache.canEdit) {
              return CupertinoButton(
                minSize: 0,
                padding: EdgeInsets.zero,
                onPressed: () => onStart(
                  context,
                  bidState.bid,
                  state.templateCache,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    color: AppColors.gray.shade9,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    Words.startTask.str,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }
            return CupertinoButton(
              minSize: 0,
              padding: EdgeInsets.zero,
              onPressed: () async {
                final result = await showUploadDialog(context) ?? false;
                if (result) {
                  onUpload(
                    context,
                    bidState.bid,
                    state.templateCache,
                  );
                }
                return;
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: AppColors.gray.shade9,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  Words.upload.str,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
