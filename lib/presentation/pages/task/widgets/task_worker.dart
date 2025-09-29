import 'package:dala_ishchisi/application/auth/auth_bloc.dart';
import 'package:dala_ishchisi/application/bid/bid_bloc.dart';
import 'package:dala_ishchisi/application/user/user_bloc.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:dala_ishchisi/common/widgets/custom_shimmer_text.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:dala_ishchisi/domain/models/user_info_model.dart';
import 'package:dala_ishchisi/main.dart';
import 'package:dala_ishchisi/presentation/routes/app_router.gr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons/heroicons.dart';

class TaskWorker extends StatelessWidget {
  final String workerId;
  final Function(String id)? onWorkerSelected;

  const TaskWorker({super.key, required this.workerId, this.onWorkerSelected});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BidBloc, BidState>(
      buildWhen: (old, e) => old.bid != e.bid,
      builder: (context, bidState) {
        return Column(
          spacing: 4,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Words.worker.str,
              style: TextStyle(
                color: AppColors.gray.shade9,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                final user = context.read<AuthBloc>().state.userInfo;
                final i = state.users.indexWhere((e) => e.id == workerId);
                final bidStateType = bidState.bid.bidState;

                if (bidStateType == BidStateType.finished ||
                    bidStateType == BidStateType.rejected ||
                    bidStateType == BidStateType.cancelled) {
                  return _Button(
                    loading: false,
                    enabled: false,
                    text: i == -1
                        ? (user.id == workerId
                            ? user.email
                            : Words.setWorker.str)
                        : state.users[i].name,
                  );
                }
                return _Button(
                  loading: state.usersStatus.isLoading ||
                      bidState.bidStatus.isLoading,
                  enabled: user.role.contains(UserRole.foreman) &&
                      state.usersStatus.isSuccess,
                  text: i == -1
                      ? (user.id == workerId ? user.email : Words.setWorker.str)
                      : state.users[i].name,
                  onTap: () {
                    router.push(UsersRoute(bidBloc: context.read<BidBloc>()));
                  },
                );
              },
            ),
          ],
        );
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
                    text.isEmpty ? Words.setWorker.str : text,
                    style: TextStyle(
                      color: AppColors.gray.shade9,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              HeroIcon(
                HeroIcons.chevronRight,
                color: AppColors.gray.shade5,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
