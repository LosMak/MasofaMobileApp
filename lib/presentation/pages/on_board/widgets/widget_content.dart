import 'package:dala_ishchisi/application/device_info/device_info_bloc.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WidgetContent extends StatelessWidget {
  final int index;

  const WidgetContent({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceInfoBloc, DeviceInfoState>(
      builder: (context, state) {
        if (state.packageInfo == null) {
          return const SizedBox();
        }
        final isMasofa =
            state.packageInfo!.appName.toLowerCase().contains('masofa');
        final key = isMasofa ? Words.boardTitle1Masofa : Words.boardTitle1Ugm;
        return Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/icons/board${index + 1}.svg',
                  height: 150),
              Text(
                index == 0 ? key.str : str('board_title${index + 1}'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.gray.shade9,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                str('board_desc${index + 1}'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.gray.shade5,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: ShapeDecoration(
                  color: AppColors.orange.shade0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  str('board_item${index + 1}_1'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.gray.shade9,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: ShapeDecoration(
                  color: AppColors.orange.shade0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  str('board_item${index + 1}_2'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.gray.shade9,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: ShapeDecoration(
                  color: AppColors.orange.shade0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  str('board_item${index + 1}_3'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.gray.shade9,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
