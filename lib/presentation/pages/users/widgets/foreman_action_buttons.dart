import 'package:dala_ishchisi/application/auth/auth_bloc.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:dala_ishchisi/domain/models/user_info_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForemanActionButtons extends StatelessWidget {
  final Function()? onCancel;
  final Function()? onSave;

  const ForemanActionButtons({super.key, this.onCancel, this.onSave});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.userInfo;
    if (user.role.contains(UserRole.worker)) return const SizedBox();

    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: CupertinoButton(
            minSize: 0,
            color: Colors.white,
            padding: EdgeInsets.zero,
            disabledColor: AppColors.gray.shade4,
            onPressed: onCancel,
            child: Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: ShapeDecoration(
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
                textAlign: TextAlign.center,
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
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: AppColors.gray.shade9,
            disabledColor: AppColors.gray.shade4,
            onPressed: onSave,
            child: Container(
              height: 28,
              width: double.infinity,
              alignment: Alignment.center,
              child: Text(
                Words.save.str,
                textAlign: TextAlign.center,
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
    );
  }
}
