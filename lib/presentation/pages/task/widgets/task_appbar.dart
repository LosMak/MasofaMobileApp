import 'package:dala_ishchisi/application/auth/auth_bloc.dart';
import 'package:dala_ishchisi/application/bid/bid_bloc.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:dala_ishchisi/common/widgets/custom_appbar_back.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:dala_ishchisi/domain/models/user_info_model.dart';
import 'package:dala_ishchisi/presentation/pages/task/widgets/cancel_dialog_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskAppbar extends StatefulWidget implements PreferredSizeWidget {
  const TaskAppbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<TaskAppbar> createState() => _TaskAppbarState();
}

class _TaskAppbarState extends State<TaskAppbar> {
  final TextEditingController controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.userInfo;

    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: 100,
      leading: const CustomAppbarBack(),
      title: Text(Words.task.str),
      actions: [
        BlocBuilder<BidBloc, BidState>(
          buildWhen: (old, e) => old.bid.bidState != e.bid.bidState,
          builder: (context, state) {
            if (user.role.contains(UserRole.worker)) return const SizedBox();

            final bidStateType = state.bid.bidState;

            if (bidStateType == BidStateType.finished ||
                bidStateType == BidStateType.rejected ||
                bidStateType == BidStateType.cancelled) {
              return const SizedBox();
            }

            return CupertinoButton(
              minSize: 0,
              padding: const EdgeInsets.all(3),
              onPressed: () async {
                final result = await showCancelDialog(
                  context,
                  title: Words.confirm.str,
                  content: Words.confirmCancel.str,
                  controller: controller,
                  formKey: formKey,
                );
                if (result) {
                  context.read<BidBloc>().add(BidEvent.cancelBid(
                        id: state.bid.id,
                        comment: controller.text,
                      ));
                }
              },
              child: Icon(
                CupertinoIcons.delete,
                color: AppColors.red.shade4,
                size: 20,
              ),
            );
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
