import 'package:dala_ishchisi/application/auth/auth_bloc.dart';
import 'package:dala_ishchisi/application/bid/bid_bloc.dart';
import 'package:dala_ishchisi/application/template/template_bloc.dart';
import 'package:dala_ishchisi/common/extensions/bid_state_extension.dart';
import 'package:dala_ishchisi/common/extensions/template_extensions.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:dala_ishchisi/common/widgets/custom_shimmer_text.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:dala_ishchisi/main.dart';
import 'package:dala_ishchisi/presentation/routes/app_router.gr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons/heroicons.dart';

class TemplateButton extends StatelessWidget {
  const TemplateButton({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.userInfo;

    return BlocBuilder<BidBloc, BidState>(
      builder: (context, bidState) {
        if (bidState.bid.workerId == user.id) {
          return BlocBuilder<TemplateBloc, TemplateState>(
            builder: (context, state) {
              if (!state.templateCache.canEdit) {
                return const SizedBox();
              }

              final status = bidState.bid.bidState.value;
              final hasAccess = [
                BidStateType.created.value,
                BidStateType.active.value,
                BidStateType.inProgress.value,
              ].contains(status);
              final loading = state.templateCache.blocks.isEmpty;
              final enabled =
                  state.templateCache.blocks.isNotEmpty && hasAccess;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Words.generalData.str,
                    style: TextStyle(
                      color: AppColors.gray.shade9,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _Button(
                    loading: loading,
                    enabled: enabled,
                    text: Words.generalData.str,
                    onTap: () {
                      router.push(GeneralTemplateRoute(
                        templateBloc: context.read<TemplateBloc>(),
                        bid: bidState.bid,
                      ));
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Words.cropMonitoring.str,
                    style: TextStyle(
                      color: AppColors.gray.shade9,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _Button(
                    loading: loading,
                    enabled: enabled,
                    text: Words.cropMonitoring.str,
                    onTap: () {
                      router.push(StepTemplateRoute(
                        templateBloc: context.read<TemplateBloc>(),
                        bid: bidState.bid,
                      ));
                    },
                  ),
                ],
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}

class _Button extends StatelessWidget {
  final String text;
  final bool loading;
  final bool enabled;
  final Function()? onTap;

  const _Button({
    this.text = '',
    required this.loading,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minSize: 0,
      padding: EdgeInsets.zero,
      onPressed: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: AppColors.gray.shade2,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (loading) const CustomShimmerText(width: 170),
              if (!loading)
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: AppColors.gray.shade9,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              HeroIcon(
                HeroIcons.pencilSquare,
                color: AppColors.green.shade5,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
